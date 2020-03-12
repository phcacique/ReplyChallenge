//
//  StreamWriter.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

public class StreamWriter{
    let encoding:String.Encoding
    var fileHandle:FileHandle!
    let delimData:NSData!
    
    init?(path:String, delimiter:String="\n", encoding:String.Encoding = .utf8){
        self.encoding = encoding
        
        //file handle
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path){
            fileManager.createFile(atPath: path,contents:nil,attributes:nil)
        }
        if let fileHandle = FileHandle(forWritingAtPath:path){
            self.fileHandle = fileHandle
        }else{
            return nil
        }
        
        //delimiter
        if let delimData = delimiter.data(using: encoding){
            self.delimData = delimData as NSData
        }else{
            return nil
        }
    }
    
    deinit{
        self.close()
    }
    
    public func writeLine(data:String)->Bool{
        if let nsData = data.data(using: encoding){
            fileHandle.write(nsData)
            fileHandle.write(delimData as Data)
            return true
        }
        return false
    }
    public func write(data:String)->Bool{
        if let nsData = data.data(using: encoding){
            fileHandle.write(nsData)
            return true
        }
        return false
    }
    
    public func close(){
        if fileHandle != nil{
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
}
