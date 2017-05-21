//
//  GoogleDriveRequestProcessor.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/4/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import SwiftyJSON

class GoogleDriveRequestProcessor: RequestProcessor {
  private let service = GTLRDriveService()
  
  init(authentication: GIDAuthentication) {
    service.authorizer = authentication.fetcherAuthorizer()
    service.callbackQueue = DispatchQueue(label: "serviceQueue",
                                          attributes: .concurrent)
  }
  
  /**
      Submits a request to the surveillance system.
 
      - Parameters:
        - request: The request to submit.
        - completionHandler: The handler that will be called once the request
                             is submitted to the surveillance system.
  */
  func submitRequest(request: Request,
                     completionHandler: @escaping (Int, Error?) -> Void) {
    let requestId = request["id"] as! Int
    let json = JSON(request)
    let text = json.rawString()!
    let filename = "pisurvl-request-\(requestId)"
    createFile(
      filename: filename,
      text: text,
      completionHandler: { (ticket, file, error) in
        completionHandler(requestId, error)
      })
  }
  
  /**
      Waits for a response to a previous request.
 
      - Parameters:
        - id: The identifier of the original request.
        - completionHandler: The handler that will be called once the response
                             has been received.
  */
  func waitForResponse(id: Int,
                       completionHandler: @escaping (Response, Error?) -> Void) {
    let queue = DispatchQueue(label: "responseQueue",
                              qos: .userInitiated,
                              attributes: .concurrent)
    var workItem: DispatchWorkItem!
    workItem = DispatchWorkItem {
      var found = false
      var fileId: String? = nil
      while !workItem.isCancelled {
        // TODO: decide how to wait for a specific response
         let responseFileName = "pisurvl-response-\(id)"
        // TODO handle error
        fileId = try! self.findFile(name: responseFileName)
        if fileId != nil {
          found = true
          break
        }
        Thread.sleep(forTimeInterval: 1)
      }
      
      if !found {
        completionHandler(Response(), ResponseError.CannotConnect)
        return
      }

      self.downloadFile(
        fileId: fileId!,
        completionHandler: { (data, error) in
          var response: Response = [:]
          if error == nil {
            let json = JSON(data: data!)
            response = json.dictionaryObject!
          }
          completionHandler(response, error)
          self.deleteFile(fileId: fileId!, completionHandler: { _ in })
        })
    }
    
    queue.async(execute: workItem)
    queue.asyncAfter(deadline: .now() + .seconds(10)) {
      workItem.cancel()
    }
  }
  
  /**
      Finds a file given its name.
   
      - Parameter name: The file name to look for.
      - Throws: `Error` if an error occurs while looking for the file.
      - Returns: The file identifier if the file was found; nil otherwise.
   
      - Important:
      This method runs synchronously (i.e., it blocks the caller).
   */
  private func findFile(name: String) throws -> String? {
    var fileId: String? = nil
    var resultError: Error? = nil
    
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    self.listFiles(
      name: name,
      completionHandler: { (ticket, fileList, error) in
        if error == nil {
          if let id = self.getFileId(name: name, files: fileList.files!) {
            fileId = id
          }
        } else {
          resultError = error
        }
        dispatchGroup.leave()
    })
    
    dispatchGroup.wait()
    
    if resultError != nil {
      throw resultError!
    } else {
      return fileId;
    }
  }
  
  /**
      Returns the file identifier that corresponds to a given file name.
 
      - Parameters:
        - name: The file name.
        - files: An array of files.
      - Returns: The file identifier corresponding to the given file name.
                 If not matching file is found, nil is returned.
  */
  private func getFileId(name: String, files: [GTLRDrive_File]) -> String? {
    var fileId: String? = nil
    // TODO Shall we check we only have one matching file?
    let idx = files.index(where: { (file) -> Bool in
      return file.name == name;
    })
    if idx != nil {
      fileId = files[idx!].identifier
    }
    return fileId;
  }
  
  /**
      Creates a file in Google Drive.
   
      - Parameters:
        - filename: The file name of the file to create.
        - text: The text that the new file will contain.
        - completionHandler: The handler that will be called when the operation
                             completes.
  */
  private func createFile(filename: String,
                          text: String,
                          completionHandler: @escaping (GTLRServiceTicket, GTLRDrive_File, Error?) -> Void) {
    let uploadParameters = GTLRUploadParameters(
      data: text.data(using: String.Encoding.utf8)!,
      mimeType: "text/plain")
    
    let file = GTLRDrive_File()
    file.name = filename
    
    // TODO shall we first check whether the file already exists?
    
    let query = GTLRDriveQuery_FilesCreate.query(
      withObject: file,
      uploadParameters: uploadParameters)
    service.executeQuery(query, completionHandler: { (ticket, file, error) in
      completionHandler(ticket, file as! GTLRDrive_File, error)
    })
  }
  
  /**
      List the files in Google Drive that match a pattern.
   
      - Parameter name: The name pattern to use to look for files.
      - Parameter completionHandler: The handler that will be called when the
                                     list of files is ready.
  */
  private func listFiles(name: String,
                         completionHandler: @escaping (GTLRServiceTicket, GTLRDrive_FileList, Error?) -> Void) {
    let query = GTLRDriveQuery_FilesList.query()
    query.q = "name='\(name)' and trashed=false"
    service.executeQuery(query) { (ticket, fileList, error) in
      let fileList = fileList as! GTLRDrive_FileList
      completionHandler(ticket, fileList, error)
    }
  }
  
  /**
      Downloads a file from Google Drive.
   
      - Parameter fileId: The file identifier.
      - Parameter completionHandler: The handler that will be called once the
                                     file is downloaded.
   */
  private func downloadFile(fileId: String,
                            completionHandler: @escaping (Data?, Error?) -> Void) {
    let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
    service.executeQuery(query) { (ticket, file, error) in
      var data: Data? = nil
      if error == nil {
        let file = file as! GTLRDataObject
        data = file.data
      }
      completionHandler(data, error)
    }
  }
  
  /**
   Deletes a file from Google Drive.
   
   - Parameter fileId: The file identifier.
   - Parameter completionHandler: The handler that will be called once the
                                  file is deleted.
   */
  private func deleteFile(fileId: String,
                            completionHandler: @escaping (GTLRServiceTicket, Error?) -> Void) {
    let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileId)
    service.executeQuery(query) { (ticket, nilObject, error) in
      completionHandler(ticket, error)
    }
  }
}
