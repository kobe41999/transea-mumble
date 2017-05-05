//
//  MHTarBarSegue.swift
//  Mumble
//
//  Created by 林子傑 on 2017/4/24.
//
//

import Foundation
import UIKit


let MHCustomTabBarControllerViewControllerChangedNotification: String = ""
let MHCustomTabBarControllerViewControllerAlreadyVisibleNotification: String = ""


class MHCustomTabBarController: UIViewController {
    
    weak var destinationViewController: UIViewController?
    var oldViewController: UIViewController?
    @IBOutlet weak var container: UIView!
    var selectedIndex: Int = 0
    var viewControllersByIdentifier = [AnyHashable: Any]()
    var destinationIdentifier: String = ""
    @IBOutlet var buttons: [UIButton]!


    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllersByIdentifier = [AnyHashable: Any]()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if childViewControllers.count < 1 {
            performSegue(withIdentifier: "viewController1", sender: buttons[0])
        }
    }
    
    func willAnimateRotation(toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        destination.view.frame = container.bounds
    }
    //pragma mark - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !(segue is MHTabBarSegue) {
            super.prepare( segue: segue, sender: sender)
            return
        }
        oldViewController = destination
        //if view controller isn't already contained in the viewControllers-Dictionary
        if !viewControllersByIdentifier[segue.identifier] {
            viewControllersByIdentifier[segue.identifier] = segue.destination
        }
        buttons.setValue(false, forKeyPath: "selected")
        sender.isSelected = true
        selectedIndex = (buttons as NSArray).index(of: sender)
        destinationIdentifier = segue.identifier
        destination = viewControllersByIdentifier[destinationIdentifier]
        NotificationCenter.default.post(name: MHCustomTabBarControllerViewControllerChangedNotification, object: nil)
    }
    
    func shouldPerformSegue(withIdentifier identifier: String, sender: Any) -> Bool {
        if destinationIdentifier.isEqual(identifier) {
            //Dont perform segue, if visible ViewController is already the destination ViewController
            NotificationCenter.default.post(name: MHCustomTabBarControllerViewControllerAlreadyVisibleNotification, object: nil)
            return false
        }
        return true
    }
    //pragma mark - Memory Warning

    override func didReceiveMemoryWarning() {
        (viewControllersByIdentifier.keys as NSArray).enumerateObjects(usingBlock: {(_ key: String, _ idx: Int, _ stop: Bool) -> Void in
            if !(destinationIdentifier == key) {
                viewControllersByIdentifier.removeValueForKey(key)
            }
        })
        super.didReceiveMemoryWarning()
    }



}
