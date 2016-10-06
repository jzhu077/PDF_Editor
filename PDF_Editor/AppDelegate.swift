//
//  AppDelegate.swift
//  PDF_Editor
//
//  Created by Junyu Zhu on 10/3/16.
//  Copyright © 2016 Junyu Zhu. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

//    @IBOutlet weak var filename_field: NSTextField!
    @IBOutlet weak var ourPDF: PDFView!
    @IBOutlet weak var totalPage: NSTextField!
    @IBOutlet weak var currentPage: NSTextField!
    @IBOutlet weak var dropDown: NSComboBox!
    @IBOutlet weak var bookmarkComboBox: NSComboBox!
    @IBOutlet weak var searchStr: NSTextField!
    @IBOutlet weak var note: NSTextField!
    @IBOutlet weak var thumbnail: PDFThumbnailView!
    @IBOutlet weak var searchNum: NSTextField!
    
    var bookmarkArr: [String] = []
    var set: [String] = []
    var PDFOpen = false
    var bookmarkDict: [String: [String]] = [:]
    var visitedPDFDict: [String: String] = [:]
    var searchResult: [AnyObject] = []
    var noteDict: [String: String] = [:]
   
    
    @IBAction func openFile(sender: AnyObject) {
        print ("try to open a file")
        let file = NSOpenPanel()
        file.title = "Choose a .pdf file"
        file.showsResizeIndicator = true
        file.showsHiddenFiles = true
        file.canChooseDirectories = true
        file.allowsMultipleSelection = false
        file.allowedFileTypes = ["pdf"]
        
        if(file.runModal() == NSModalResponseOK){
            let result = file.URL
            if (result != nil){
                _ = result!.path
//                filename_field.stringValue = path
                
                ourPDF.setAutoScales(true)
                ourPDF.setDocument(PDFDocument(URL: file.URL))
                thumbnail.setPDFView(ourPDF)
                thumbnail.setThumbnailSize(NSSize.init(width: 50, height: 50))
                PDFOpen = true
                updateBookmark(String(file.URL!))
                updateNote()
                if(visitedPDFDict[String(file.URL!)] == nil){
                    set.append(String(file.URL!))
                    print(set)
                    dropDown.removeAllItems()
                    dropDown.addItemsWithObjectValues(set)
                    visitedPDFDict[String(file.URL!)] = "visited"
                }
                
                dropDown.stringValue = String(result!)
                if let n: Int = ourPDF.document().pageCount() {
                    totalPage.stringValue = "/ \(n)"
                }
                
                currentPage.stringValue = "1"
                
            } else {
                return
            }
        }
    }
    @IBAction func zoomIn(sender: AnyObject) {
        if(PDFOpen){
        ourPDF.zoomIn(self)
        }
    }
    @IBAction func zoomOut(sender: AnyObject) {
        if(PDFOpen){
        ourPDF.zoomOut(self)
        }
    }
    @IBAction func zoomToFit(sender: AnyObject) {
        ourPDF.setAutoScales(true)
    }
    @IBAction func nextPage(sender: AnyObject) {
        if(PDFOpen){
        if(ourPDF.canGoToNextPage()){
            ourPDF.goToNextPage(self)
            currentPage.stringValue = String(Int(currentPage.stringValue)!)
        }else{
            print("End of the PDF")
        }
        }
    }
    @IBAction func previousPage(sender: AnyObject) {
        if(PDFOpen){
        if(ourPDF.canGoToPreviousPage()){
            ourPDF.goToPreviousPage(self)
            currentPage.stringValue = String(Int(currentPage.stringValue)!)
        }else{
            print("Top of the PDF")
        }
        }
    }
    
    //Page jump function. It will activate when the page text field is changed
    @IBAction func page(sender: NSTextField) {
        if(PDFOpen){
        print(sender.stringValue)
        
        if let pageCount: Int  = ourPDF.document().pageCount(){
            // page number between 1 and total page
            if(Int(sender.stringValue)!-1 < pageCount && Int(sender.stringValue)! >= 1){
                if let jump = ourPDF.document().pageAtIndex(Int(sender.stringValue)!-1) {
                    ourPDF.goToPage(jump)
                }
            // page number less than 1
            }else if (Int(sender.stringValue)! < 1){
                ourPDF.goToPage(ourPDF.document().pageAtIndex(0)!)
                currentPage.stringValue = "1"
            // page number greater than total page
            }else {
                ourPDF.goToPage(ourPDF.document().pageAtIndex(pageCount-1)!)
                currentPage.stringValue = pageCount.description
            }
        }
        }
    }
    
    @IBAction func nextDoc(sender: AnyObject) {
        if(PDFOpen){
        var current: Int = dropDown.indexOfItemWithObjectValue(dropDown.stringValue)
        if (current+1) < dropDown.numberOfItems {
            print(current)
            current = current + 1
        }
        ourPDF.setDocument(PDFDocument(URL: NSURL(string: dropDown.itemObjectValueAtIndex(current) as! String)))
        
        dropDown.stringValue = dropDown.itemObjectValueAtIndex(current) as! String
        updateBookmark(String(ourPDF.document().documentURL()))
            updateNote()
//        print(ourPDF.document().documentURL().lastPathComponent)
//        if let folderPath = ourPDF.document().documentURL().URLByDeletingLastPathComponent!.path {
//            print(String(folderPath))
//            let fileManager: FileManager = FileManager.init()
//            
//                let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: folderPath)!
//
//            var currentPage = false;
//            while let element = enumerator.nextObject() as? String {
//                print (element)
//                
//                if (element.hasSuffix("pdf") && currentPage) { // checks the extension
//                        let combine: String = folderPath + "/" + element.description
//                        print(combine)
//                        ourPDF.document = PDFDocument(url: NSURL(fileURLWithPath: combine) as URL)
//                        break;
//                }
//                if element == ourPDF.document?.documentURL?.lastPathComponent {
//                    currentPage = true
//                }
//            }
//        }
        }
    }
    @IBAction func prevDoc(sender: AnyObject) {
        if(PDFOpen){
        var current: Int = dropDown.indexOfItemWithObjectValue(dropDown.stringValue)
        print(current)
        if (current-1) >= 0 {
            print(current)
            current = current - 1
        }
        ourPDF.setDocument(PDFDocument(URL: NSURL(string: dropDown.itemObjectValueAtIndex(current) as! String)))
        dropDown.stringValue = dropDown.itemObjectValueAtIndex(current) as! String
            updateBookmark(String(ourPDF.document().documentURL()))
            updateNote()
//        print(ourPDF.document?.documentURL?.lastPathComponent)
//        if let folderPath = ourPDF.document?.documentURL?.deletingLastPathComponent().path {
//            print(String(folderPath.description)!)
//            let fileManager: FileManager = FileManager.init()
//            
//            let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: folderPath)!
//            
//            var currentPage = false;
//            var tempElement: String = "";
//            while let element = enumerator.nextObject() as? String {
//                //print (element)
//                if element == ourPDF.document?.documentURL?.lastPathComponent {
//                    currentPage = true
//                }
//                if (element.hasSuffix("pdf") && currentPage) { // checks the extension
//                    let combine: String
//                    if(tempElement == ""){
//                         combine = folderPath + "/" + element.description
//                    }else{
//                         combine = folderPath + "/" + tempElement.description
//
//                    }
//                    print(combine)
//                    ourPDF.document = PDFDocument(url: NSURL(fileURLWithPath: combine) as URL)
//                    break;
//                }
//                if element.hasSuffix("pdf") {
//                    tempElement = element
//                    print(tempElement)
//                }
//            }
//        }
        }
    }
    @IBAction func goToDoc(sender: AnyObject) {
        ourPDF.setDocument(PDFDocument(URL: NSURL(string:
            dropDown.stringValue)))
        updateBookmark(dropDown.stringValue)
    }
    @IBAction func addNote(sender: AnyObject){
        if(PDFOpen){
        let page: String = ourPDF.currentPage().label()
        let url: String = String(ourPDF.document().documentURL())
            noteDict [url + page] = note.stringValue
        }
    }
    @IBOutlet weak var annotationText: NSTextField!
    @IBAction func addAnnotationText(sender: AnyObject) {
        if(PDFOpen){
            //things to mention
            ourPDF.setDisplayMode(kPDFDisplaySinglePage)
            ourPDF.setAutoScales(true)
            let rect = NSRect(x: 20, y: 20, width: 200, height: 200)
            //let rect = ourPDF.currentPage().boundsForBox(1)
            let anno = PDFAnnotationFreeText(bounds: rect)
            
            anno.setShouldDisplay(true)
            //anno.setIsMultiline(true)
            anno.setColor(NSColor.redColor())
            anno.setContents(annotationText.stringValue)
            //print(anno.stringValue())
            ourPDF.currentPage().addAnnotation(anno)
            print("did something")
        }
        
//        print("addNote")
//        let rect = NSRect(x: 20, y: 20, width: 200, height: 200)
//        let note = NSTextField(frame: NSMakeRect(20,20,200,200))
//        note.drawsBackground = true
//        note.backgroundColor = NSColor(red: 1, green: 1, blue: 0.8, alpha: 128) //light yellow
//        ourPDF.addSubview(note)
//        note.tag = 111
//        let noteFinished: NSNotification = NSNotification.init(name: "NoteFinished", object: nil)
        
        //NSNotificationCenter.defaultCenter().postNotification(noteFinished)
        //note.textDidEndEditing(noteFinished)
        //note.bind(note.stringValue, toObject: note, withKeyPath: "self", options: nil)
//       let anno = PDFAnnotationTextWidget(bounds: rect)
//        anno.setIsMultiline(true)
//        anno.setStringValue()
    }
    @IBAction func addBookmark(sender: AnyObject) {
        if(PDFOpen && bookmarkDict[String(ourPDF.document().documentURL())] == nil){
            bookmarkArr.append("Page " + String(ourPDF.document().indexForPage(ourPDF.currentPage())+1))
            //print(ourPDF.document().indexForPage(ourPDF.currentPage()))
            //bookMarkComboBox.removeAllItems()
            bookmarkComboBox.addItemWithObjectValue("Page " + String(ourPDF.document().indexForPage(ourPDF.currentPage())+1))
            bookmarkComboBox.stringValue = "Page " + String(ourPDF.document().indexForPage(ourPDF.currentPage())+1)
            print(String(ourPDF.document().documentURL()))
            bookmarkDict[String(ourPDF.document().documentURL())] = bookmarkArr
        }
    }
    @IBAction func goToBookmark(sender: AnyObject) {
        if(PDFOpen){
            if(bookmarkComboBox.stringValue != "Bookmark"){
                if let n: Int = Int(bookmarkComboBox.stringValue.characters.split{$0 == " "}.map(String.init)[1])!-1 {
                    ourPDF.goToPage(ourPDF.document().pageAtIndex(n))
                }
            }
        }
    }
    func updateBookmark(url: String){
        if let _ = bookmarkDict[url]{
            bookmarkComboBox.removeAllItems()
            bookmarkComboBox.addItemsWithObjectValues(bookmarkDict[url]!)
            bookmarkArr = bookmarkDict[url]!
            bookmarkComboBox.stringValue = "Bookmark"
        }else{
            bookmarkArr = []
            bookmarkComboBox.removeAllItems()
            bookmarkComboBox.stringValue = "Bookmark"
        }
    }
    var searchIndex = 0
    @IBAction func search(sender: AnyObject) {
        if(PDFOpen){
            
            
            if  !searchStr.stringValue.isEmpty {
                searchResult = ourPDF.document().findString(searchStr.stringValue, withOptions: 1)
                if(searchResult.count>0){
                    let n = searchResult[0] as! PDFSelection
                    ourPDF.goToPage(n.pages()[0] as! PDFPage)
                    let _ = searchResult[0] as! PDFSelection
                    ourPDF.setCurrentSelection(n, animate: true)
                    searchResult[0].setColor(NSColor.yellowColor())
                    //searchNum.stringValue = "1/" + String(searchResult.count)
                }
            }
        }
        
    }
    @IBAction func prevSearchResult(sender: AnyObject) {
        if(PDFOpen){
            if((searchIndex-1)>=0){
                searchIndex -= 1
                searchResult = ourPDF.document().findString(searchStr.stringValue, withOptions: 1)
                let n = searchResult[searchIndex] as! PDFSelection
                ourPDF.goToPage(n.pages()[0] as! PDFPage)
                let _ = searchResult[searchIndex] as! PDFSelection
                ourPDF.setCurrentSelection(n, animate: true)
                searchResult[searchIndex].setColor(NSColor.yellowColor())
                searchNum.stringValue = String(searchIndex+1) + "/" + String(searchResult.count)
            }
        }
    }
    @IBAction func nextSearchResult(sender: AnyObject) {
        
        if(PDFOpen){
            if((searchIndex+1) < searchResult.count){
                searchIndex += 1
                
                searchResult = ourPDF.document().findString(searchStr.stringValue, withOptions: 1)
                let n = searchResult[searchIndex] as! PDFSelection
                ourPDF.goToPage(n.pages()[0] as! PDFPage)
                let _ = searchResult[searchIndex] as! PDFSelection
                ourPDF.setCurrentSelection(n, animate: true)
                searchResult[searchIndex].setColor(NSColor.yellowColor())
                searchNum.stringValue = String(searchIndex+1) + "/" + String(searchResult.count)
            }
        }
    }
    
    func updateCurrentPage (){
        
        currentPage.stringValue = String(ourPDF.document().indexForPage(ourPDF.currentPage()) + 1)
    }
    func updateNote (){
//        let textField: NSTextField = ourPDF.viewWithTag(111) as! NSTextField
//        print(textField.stringValue)
        if (PDFOpen){
        let page: String = ourPDF.currentPage().label()
        let url: String = String(ourPDF.document().documentURL())
        if(PDFOpen && noteDict[url+page] != nil){
            note.stringValue = noteDict[url+page]!
        }else{
            note.stringValue = ""
        }
        }
    }
    @IBAction func pointToSearch(sender: AnyObject){
        print("search")
        searchStr.becomeFirstResponder()
    }
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
//        let mySize = NSSize(width:1000, height: 400)
//        print("mySize is \(mySize.width) wide and \(mySize.height)")
        if let bd = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().resourcePath! + "/answers/aa") as? [String:[String]] {
            bookmarkDict = bd
            print("loaded")
        }else {print("Cannot find bookmarkDict")}
        if let nd = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().resourcePath! + "/answers/bb") as? [String:String] {
            noteDict = nd
            print("loaded")
        }else {print("Cannot find noteDict")}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateCurrentPage), name: PDFViewPageChangedNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateNote), name: "NoteFinished", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateNote), name: PDFViewPageChangedNotification, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
//        print(NSBundle.mainBundle().resourcePath! + "/answers/344-2015lab04_ans.pdf")
//        ourPDF.setDocument(PDFDocument(URL: NSURL.fileURLWithPath( NSBundle.mainBundle().resourcePath! + "/answers/344-2015lab04_ans.pdf")))
        if(NSKeyedArchiver.archiveRootObject(bookmarkDict, toFile: NSBundle.mainBundle().resourcePath! + "/answers/aa")){
            print("good")
            print(NSBundle.mainBundle().resourcePath! + "/answers/bd")
        }else{
            print("sad")
        }
        NSKeyedArchiver.archiveRootObject(noteDict, toFile: NSBundle.mainBundle().resourcePath! + "/answers/bb")
    }


}

