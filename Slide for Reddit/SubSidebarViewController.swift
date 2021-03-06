//
//  SubSidebarViewController.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 1/11/17.
//  Copyright © 2016 Haptic Apps. All rights reserved.
//

import Anchorage
import reddift
import SDWebImage
import UIKit

class SubSidebarViewController: MediaViewController, UIGestureRecognizerDelegate {
    var scrollView = UIScrollView()
    var subreddit: Subreddit?
    var filteredContent: [String] = []
    var parentController: (UIViewController & MediaVCDelegate)?

    init(sub: Subreddit, parent: UIViewController & MediaVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.subreddit = sub
        self.parentController = parent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: subbed)
        setupBaseBarColors(ColorUtil.getColorForSub(sub: (subreddit?.displayName)!))
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    func doSubreddit(sub: Subreddit, _ width: CGFloat) {
        header.setSubreddit(subreddit: sub, parent: self, width)
        header.frame.size.height = header.getEstHeight()
        header.frame.size.width = self.view.frame.size.width
        scrollView.contentSize = header.frame.size
        scrollView.addSubview(header)
        header.leftAnchor == scrollView.leftAnchor
        header.topAnchor == scrollView.topAnchor
        scrollView.clipsToBounds = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        header.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func close(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    var subbed = UISwitch()
    var header: SubredditHeaderView = SubredditHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = CGRect.zero
        self.setBarColors(color: ColorUtil.getColorForSub(sub: subreddit!.displayName))

        subbed.isOn = Subscriptions.isSubscriber(subreddit!.displayName)
        subbed.onTintColor = ColorUtil.accentColorForSub(sub: subreddit!.displayName)
        subbed.addTarget(self, action: #selector(doSub(_:)), for: .valueChanged)

        self.view.addSubview(scrollView)
        scrollView.edgeAnchors == self.view.edgeAnchors
        title = subreddit!.displayName
        self.setupBaseBarColors()
        color = ColorUtil.getColorForSub(sub: subreddit!.displayName)
        
        setNavColors()
        
        scrollView.backgroundColor = ColorUtil.backgroundColor
        
        self.doSubreddit(sub: subreddit!, UIScreen.main.bounds.width)
    }

    func doSub(_ changed: UISwitch) {
        if !changed.isOn {
            Subscriptions.unsubscribe(subreddit!.displayName, session: (UIApplication.shared.delegate as! AppDelegate).session!)
            BannerUtil.makeBanner(text: "Unsubscribed from r/\(subreddit!.displayName)", color: ColorUtil.accentColorForSub(sub: subreddit!.displayName), seconds: 3, context: self, top: true)
            
        } else {
            let alrController = UIAlertController.init(title: "Follow \(subreddit!.displayName)", message: nil, preferredStyle: .actionSheet)
            if AccountController.isLoggedIn {
                let somethingAction = UIAlertAction(title: "Subscribe", style: UIAlertActionStyle.default, handler: { (_: UIAlertAction!) in
                    Subscriptions.subscribe(self.subreddit!.displayName, true, session: (UIApplication.shared.delegate as! AppDelegate).session!)
                    BannerUtil.makeBanner(text: "Subscribed to r/\(self.subreddit!.displayName)", color: ColorUtil.accentColorForSub(sub: self.subreddit!.displayName), seconds: 3, context: self, top: true)
                })
                alrController.addAction(somethingAction)
            }
            
            let somethingAction = UIAlertAction(title: "Casually subscribe", style: UIAlertActionStyle.default, handler: { (_: UIAlertAction!) in
                Subscriptions.subscribe(self.subreddit!.displayName, false, session: (UIApplication.shared.delegate as! AppDelegate).session!)
                BannerUtil.makeBanner(text: "r/\(self.subreddit!.displayName) added to your subreddit list", color: ColorUtil.accentColorForSub(sub: self.subreddit!.displayName), seconds: 3, context: self, top: true)
            })
            alrController.addAction(somethingAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction!) in print("cancel") })
            
            alrController.addAction(cancelAction)
            
            alrController.modalPresentationStyle = .fullScreen
            if let presenter = alrController.popoverPresentationController {
                presenter.sourceView = changed
                presenter.sourceRect = changed.bounds
            }
            
            self.present(alrController, animated: true, completion: {})
        }
    }

}
