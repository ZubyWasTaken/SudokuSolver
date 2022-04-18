//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Zubair Khalid.
//

import UIKit
import Vision
import VisionKit


//Declare the structure where the data is stored
struct DataValue{
    let value: String
    let column: Int
    let row: Int
    
    init(value: String, column: Int, row: Int){
        self.value = (1...9).map({String($0)}).contains(value) ? value: "1"
        self.column = column
        self.row = row
    }
}


class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    //Declare variables
    @IBOutlet weak var sudokuView: SudokuView!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var solveBtn: UIButton!
    
    var scannedData: [DataValue] = [] {
        didSet{
            //if the scannedData variable is not empty, the solve button is enabled.
            solveBtn.isEnabled = !scannedData.isEmpty
        }
    }
    
    var solved_data: [DataValue] = []
    var textRecognitionReq = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "ScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets the solve button as false initially
        solveBtn.isEnabled = false
        
        setupVision()
    }
    
    // the scan buttons action creates the view controller which shows what the document camera sees
    @IBAction func actionScanBtn(_ sender: Any){
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
    
    // this function processes the scanned data, and presents it to be displayed to
    // the sudoku square
    func processScannedData(_ scannedData: [DataValue]) {
        self.scannedData = scannedData
        let dataSource = SudokuView.Data(pairsInitial: scannedData,
                                         pairsSolved: [])
        print(dataSource)
        sudokuView.setDataSource(dataSource)
    }
    
    @IBAction func solveButtonAction(_ sender: Any) {
        //logic for solving the puzzle goes here
        
    }
    
    
    
}

// add new functionality to ViewController class
extension ViewController {
    
    // creates a range for the elements counted
    func closedRangeForElementsCount(_ count: Int, reversedIndex: Bool = false) -> [(ClosedRange<CGFloat>, Int)] {
        var ranges: [(ClosedRange<CGFloat>, Int)] = []
        
        let absoluteLength: CGFloat = 1.0/CGFloat(count);
        for i in 0..<count {
            let leftBound = CGFloat(i) * absoluteLength
            let rightBound = leftBound + absoluteLength
            ranges.append((leftBound...rightBound, reversedIndex ? count - (i + 1) : i))
        }
        return ranges
    }
    
    
    // sets up the vision framework and scans the numbers
    private func setupVision(){
        
        let rangeHorizontal = closedRangeForElementsCount(9)
        let rangeVertical = closedRangeForElementsCount(9, reversedIndex: true)
        
        // creates an image analysis request which finds and recognises text in an image
        textRecognitionReq  = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations =  request.results as? [VNRecognizedTextObservation] else {return}
            
            var data: [DataValue] = []
            
            // for every observation in the resulted request of information scanned in
            for observation in observations{
                guard let canditateTop = observation.topCandidates(1).first else {return}
                
                let centerCandidate = observation.boundingBox.absoluteCenter
                
                var text = canditateTop.string
                if canditateTop.string == "1" {
                    var countOne = 0
                    for candidate in observation.topCandidates(9){
                        if (candidate.string == "1"){
                            countOne += 1
                        }
                    }
                    
                    if countOne > 5 {
                        text = "1"
                    }
                }
                
                // sorts through the scanned information, finds out which row and column it is (starting at 0)
                // and stores the number as a String, and the index of the row/column into the DataValue Struct which is in an array
                if text.count > 1{
                    let textTrimmed = text.trimmingCharacters(in: .whitespaces)
                    let width = observation.boundingBox.width / CGFloat(textTrimmed.count)
                    let yCenter = observation.boundingBox.origin.y + observation.boundingBox.height / 2
                    let xOrigin = observation.boundingBox.origin.y
                    
                    for (index, char) in textTrimmed.enumerated() {
                        let xCenter = xOrigin + CGFloat(index) * (width/CGFloat(text.count))
                        let center  = CGPoint(x: xCenter, y: yCenter)
                        
                        if let indexHorizontal = rangeHorizontal.first(where: { $0.0.contains(center.x) })?.1,
                           let indexVertical = rangeVertical.first(where: { $0.0.contains(center.y) })?.1 {
                            data.append(DataValue(value: String(char), column: indexHorizontal, row: indexVertical))
                        }
                    }
                } else{
                    if let indexHorizontal = rangeHorizontal.first(where: { $0.0.contains(centerCandidate.x) })?.1,
                       let indexVertical = rangeVertical.first(where: { $0.0.contains(centerCandidate.y) })?.1 {
                        data.append(DataValue(value: text, column: indexHorizontal, row: indexVertical))
                    }
                }
            }
            DispatchQueue.main.async {
                [weak self] in
                self?.processScannedData(data)
            }
        }
        // sets the level of the recognition of the request
        // .accurate = more accurate, but slower
        // .fast = less acurate, but faster
        textRecognitionReq.recognitionLevel = .accurate
        
        // tells the request to look out for specific Strings, in this instance the numbers 1 to 9 (inclusive)
        textRecognitionReq.customWords = (1...9).map({String($0) })
    }
    
    // called by the act of the image being scanneed
    private func processImage(_ image: UIImage){
        recognizeTextImage(image)
    }
    
    // handes the request to recognise the text in the image
    private func recognizeTextImage(_ image: UIImage){
        guard let cgImage = image.cgImage else {return}
        
        textRecognitionWorkQueue.async {
            let handleReq = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do{
                try handleReq.perform([self.textRecognitionReq])
            } catch {
                print(error)
            }
        }
    }
    
    // gets the image scanned by the camera
    // sets the variable imageNew to a compressed version of the original image
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // if there isnt 1 ore more pages scanned, dismiss
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        let imageOriginal = scan.imageOfPage(at: 0)
        let imageNew = compressImage(imageOriginal)
        controller.dismiss(animated: true)
        
        // calls process image func
        processImage(imageNew)
    }
    
    // handles dismissing the controlled if it failed with an error
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    //dismisses the controller if didnt fail with error
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    // compresses the image
    func compressImage(_ imageOriginal: UIImage) -> UIImage {
        
        // compress the image by calling jpedData function
        // if successful return the compressed image
        // if failed, return the original image
        guard let imageData = imageOriginal.jpegData(compressionQuality: 1),
              let reloadImage = UIImage(data: imageData) else{
            return imageOriginal
        }
        return reloadImage
    }
    
    
    
    
}

extension CGRect {
    
    //defines an absolute center
    var absoluteCenter: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }
}
