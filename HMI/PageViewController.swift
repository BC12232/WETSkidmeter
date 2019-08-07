//
//  PageViewController.swift
//  WETSkidmeter4
//
//  Created by Bethany Chen on 8/2/19.
//  Copyright © 2019 Bethany Chen. All rights reserved.
//

import UIKit
class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "sb1"),
                self.newVc(viewController: "sb2")]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    func newVc(viewController: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController)
            else{
                return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else{
            return orderedViewControllers.last
        }
        guard orderedViewControllers.count > previousIndex else{
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController)
            else{
                return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else{
            return orderedViewControllers.first
        }
        guard orderedViewControllers.count > nextIndex else{
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
