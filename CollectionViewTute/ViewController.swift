//
//  ViewController.swift
//  CollectionViewTute

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var tableImages: [String] = ["0.jpg", "1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "0.jpg", "1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg"]
    var exposed: NSMutableArray = []
    var back: UIImageView!
    var front: UIImageView!
    var card1: NSIndexPath!
    var card2: NSIndexPath!
    var state = 0
    var playersTurn = true
    var closed: NSMutableArray = []
    var myInterval = NSTimer()
    var audioPlayer: AVAudioPlayer!
    var shownClosedCells: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.whiteColor()
        createExposed(exposed)
        tableImages = tableImages.shuffle()
    }
    
    func createExposed(exposed: NSMutableArray) {
        // Creates an array to track cards state
        for _ in 1...tableImages.count {
            exposed.addObject("false")
        }
    }
    
    func playSound(sound: String) {
        do {
            self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "wav")!))
            self.audioPlayer.play()
            
        } catch {
            print("Error")
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: colvwCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! colvwCell
        cell.imgCell.image = UIImage(named: "pattern")
        return cell
    }
    
    func allClosed(collectionView: UICollectionView) -> NSMutableArray {
        // Returns an array of indexes for all closed cards
        closed = []
        for cell in collectionView.visibleCells() as [UICollectionViewCell] {
            let indexPath = collectionView.indexPathForCell(cell)
            if exposed[indexPath!.row] as! String == "false" {
                closed.addObject(collectionView.indexPathForCell(cell)!)
            }
        }
        return closed
    }
    
    func botPlay(collectionView: UICollectionView) {
        if allClosed(collectionView).count > 0 {
            var openCellInd = allClosed(collectionView)[Int(arc4random_uniform(UInt32(allClosed(collectionView).count)))]
            var openCell = collectionView.cellForItemAtIndexPath(openCellInd as! NSIndexPath) as! colvwCell
            if state == 1 && shownClosedCells.count > 0 {
                for item in shownClosedCells {
                    let ind = collectionView.indexPathForCell(item as! UICollectionViewCell)
                    if tableImages[ind!.row] == tableImages[card1.row] {
                        openCell = item as! colvwCell
                        openCellInd = collectionView.indexPathForCell(openCell)!
                    }
                }
            }
            openCell.imgCell.image = UIImage(named: tableImages[openCellInd.row])
            exposed[openCellInd.row] = "true"
            shownClosedCells.removeObject(openCell)
            playSound("blub")
            if state == 0 {
                card1 = openCellInd as! NSIndexPath
                state = 1
            } else if state == 1 {
                card2 = openCellInd as! NSIndexPath
                state = 0
                if tableImages[card1.row] != tableImages[card2.row] {
                    let cell1 = collectionView.cellForItemAtIndexPath(card1) as! colvwCell
                    let cell2 = collectionView.cellForItemAtIndexPath(card2) as! colvwCell
                    exposed[card1.row] = "false"
                    exposed[card2.row] = "false"
                    let myTimeout = setTimeout(0.5, block: { () -> Void in
                        cell1.imgCell.image = UIImage(named: "pattern")
                        cell2.imgCell.image = UIImage(named: "pattern")
                        self.shownClosedCells.addObject(cell1)
                        self.shownClosedCells.addObject(cell2)
                    })
                    playersTurn = true
                    collectionView.userInteractionEnabled = true
                    myInterval.invalidate()
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if playersTurn == true {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! colvwCell
            let isOpen = exposed[indexPath.row]
            if (isOpen as! String == "false") {
                cell.imgCell.image = UIImage(named: tableImages[indexPath.row])
                exposed[indexPath.row] = "true"
                shownClosedCells.removeObject(cell)
                playSound("blub")
            }
            if state == 0 {
                card1 = indexPath
                state = 1
            } else if state == 1 {
                card2 = indexPath
                state = 0
                if tableImages[card1.row] != tableImages[card2.row] {
                    let cell1 = collectionView.cellForItemAtIndexPath(card1) as! colvwCell
                    let cell2 = collectionView.cellForItemAtIndexPath(card2) as! colvwCell
                    exposed[card1.row] = "false"
                    exposed[card2.row] = "false"
                    shownClosedCells.addObject(cell1)
                    shownClosedCells.addObject(cell2)
                    let myTimeout = setTimeout(0.5, block: { () -> Void in
                        cell1.imgCell.image = UIImage(named: "pattern")
                        cell2.imgCell.image = UIImage(named: "pattern")
                    })
                    playersTurn = false
                    collectionView.userInteractionEnabled = false
                    myInterval = setInterval(1.0, block: { () -> Void in
                        if self.playersTurn == false {
                            self.botPlay(collectionView)
                        }
                    })
                }
            }
        }
    }

}

// Helper functions to shuffle array

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

// Helper functions to set timeout and interval

func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
    return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: false)
}

func setInterval(interval:NSTimeInterval, block:()->Void) -> NSTimer {
    return NSTimer.scheduledTimerWithTimeInterval(interval, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: true)
}

