//
//  SudokuView.swift
//  SudokuSolver
//
//  Created by Zubair Khalid.
//

import UIKit

class SudokuView: UIView {
    
    
    //defines constants to be used
    private enum Constants {
        
        static let rows = 9
        static let columns = 9
        
        static let offset: CGFloat = 1.5
        static let separation = 3
        
        static let outlineMinor: CGFloat = 1.5
        static let outlineMajor: CGFloat = 2.5
        
        static let strokeColour = UIColor.darkGray
        static let colourInitialValue = UIColor.darkGray
        static let colourSolvedValue = UIColor(red: 42/255, green: 193/255, blue: 42/255, alpha: 1.0)
    }
    
    //sets the variable data to the struct data
    private var dataSource: Data?
    
    // pairsInitial are the scanned unsolved numbers
    struct Data {
        let pairsInitial: [DataValue]
        
        // pairs solved is unused
        let pairsSolved: [DataValue]
    }
    
    // sorts out user interface stuff
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // sends the information that needs to be sent to the user interface to be displayed
    func setDataSource(_ dataSource: Data) {
        self.dataSource = dataSource
        setNeedsDisplay()
    }
    
    // triggers a layour update
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //function to draw the initial values (scanned data)
    // to draw the solved values
    // to draw the outlines of the sodoku square
    override func draw(_ rect: CGRect){
        super.draw(rect)
        drawPairsInitialValue()
        drawPairsSolvedValue()
        drawOutlines()
    }
}


//extends functionality of the class
private extension SudokuView {
    
    
    // draws the initial value (scanned numbers) to the square
    func drawPairsInitialValue(){
        guard let pairsInitial = dataSource?.pairsInitial else{
            return
        }
        
        // for each number ->
        // assigns a row and column for that number in the rectangle
        // draw the number in that specific row and column
        for pair in pairsInitial{
            let rect =  rectForColumn(pair.column, andRow: pair.row)
            drawText(pair.value, textColour: Constants.colourInitialValue, rect: rect)
        }
    }
    
    // does the same as drawPairsInitialValue except its for the solved numbers
    func drawPairsSolvedValue(){
        guard let pairsSolved = dataSource?.pairsSolved else{
            return
        }
        
        for pair in pairsSolved {
            let rect = rectForColumn(pair.column, andRow: pair.row)
            drawText(String(pair.value), textColour: Constants.colourSolvedValue, rect: rect)
        }
    }
    
    // function to draw the actual text
    func drawText(_ text: String, textColour: UIColor, font: UIFont = UIFont.systemFont(ofSize: 25.0), rect: CGRect){
        let styleParagraph = NSMutableParagraphStyle()
        styleParagraph.alignment = .center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: styleParagraph,
            .font: font,
            .foregroundColor: textColour
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: rect)
    }
    
    // draws the outlines of the sodoku square
    func drawOutlines() {
        
        // variables to define where the start and end of the column is
        let indexFirstColumn = 0
        let columnIndexLast = Constants.columns - 1
        
        // variables to define where the start and end of the row is
        let indexFirstRow = 0
        let rowIndexLast = Constants.columns - 1
        
        let context = UIGraphicsGetCurrentContext()
        
        // for every number from 1 - 9
        // (starts at 0, so to make it 9 you do + 1 to columnIndexLast)
        for i in indexFirstColumn...columnIndexLast + 1 {
            
            // handles bolding for each column
            let boldedColumnLine = i == indexFirstColumn || (i) % Constants.separation == 0
            let widthStroke = boldedColumnLine ? Constants.outlineMajor : Constants.outlineMinor
            context?.setLineWidth(widthStroke)
            
            context?.move(to: CGPoint(x: originX + CGFloat(i) * interRowsSpacing, y: originY))
            
            context?.addLine(to: CGPoint(x: originX + CGFloat(i) * interRowsSpacing, y: originY + size))
            
            context?.setStrokeColor(Constants.strokeColour.cgColor)
            context?.strokePath()
        }
        
        //handles bolding for each row
        for i in indexFirstRow...rowIndexLast + 1 {
            let boldedColumnLine = i == indexFirstRow || (i) % Constants.separation == 0
            let widthStroke = boldedColumnLine ? Constants.outlineMajor : Constants.outlineMinor
            context?.setLineWidth(widthStroke)
            
            context?.move(to: CGPoint(x: originX, y: originY + CGFloat(i) * interColumnsSpacing))
            
            context?.addLine(to: CGPoint(x: originX + size, y: originY + CGFloat(i) * interColumnsSpacing))
            context?.setStrokeColor(Constants.strokeColour.cgColor)
            context?.strokePath()
        }
        
    }
    
    //creates a rectangle
    func rectForColumn(_ column: Int, andRow row: Int) -> CGRect {
        let x = originX + CGFloat(column) * interColumnsSpacing
        let y = originY + CGFloat(row) * interRowsSpacing
        
        return CGRect(x: x, y: y, width: interColumnsSpacing, height: interRowsSpacing)
    }
    
    //additional variables used in drawing
    var width: CGFloat {
        return bounds.width - Constants.offset
    }
    
    var height: CGFloat {
        return bounds.height - Constants.offset
    }
    
    var size: CGFloat {
        return min(width, height)
    }
    
    var cenetBounds: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
    
    var originX: CGFloat {
        return cenetBounds.x - size / 2 + Constants.offset / 2
    }
    
    var originY: CGFloat {
        return cenetBounds.y - size / 2 + Constants.offset / 2
    }
    
    var interColumnsSpacing: CGFloat {
        return size / CGFloat(Constants.columns)
    }
    
    var interRowsSpacing: CGFloat {
        return size / CGFloat(Constants.rows)
    }
    
    
    
    
}
