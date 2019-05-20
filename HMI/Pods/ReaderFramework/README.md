
## PDF Reader Core for iOS 7

### Introduction

I loved the original version of this project. It was the only decent open source PDF reader for iOS. The one caveat for me was its incredibly dated UI. So with this in mind, I forked the project and optimised the UI for iOS 7 and added a few more necessary tweaks.

### What's New
Here's a list of the changes I've made for the initial version:

* Optimised UI for iOS 7 style.
* Implemented fast pagination as per [this pull request](https://github.com/vfr/Reader/pull/48).
* Ditched the ReaderMainToolbar for the top toolbar. The viewer now uses the current UINavigationController's nav bar. **Note: this means the the viewer is required to be shown in a UINavigationController isntance. See below.** 
* Ditched cluttered bar button items in favor of two UIBarButtonItems.
* Added ability to open PDF in other apps.
* Moved all framework files into dedicated folder (ReaderFramework).
* Moved assets into Reader.bundle file in /ReaderFramework.
* Added UIPopover approach for iPad actions (see [here](http://imgur.com/rg25feZ)).
* Added ability to embed ReaderViewController's view in a UIViewController's subview (and still have nav bar support).

Here's how it looks now:

![iPod Page](http://i.imgur.com/GPL2Gn2.png)
![iPod Page](http://i.imgur.com/551VLUx.png)
![iPod Page](http://i.imgur.com/0nrtfWd.png)

### Installation
Cocoapods of course!

```
pod 'ReaderFramework', '~> 1.1.3'
```

### Usage
As mentioned above, you now need to show the ReaderViewController instance in UINavigationController stack. So if you want to push it onto the stack, simply:

```objectivec

-(void)pushShowPDFReader:(id)sender {
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mydocument" ofType:@"pdf"];
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];

	ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
	readerViewController.delegate = self;
	
	[self.navigationController pushViewController:readerViewController animated:YES];
}
```

You can also display it modally, but you need to show it in a UINavigationController:

```objectivec

-(void)pushShowPDFReaderModally:(id)sender {
   
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mydocument" ofType:@"pdf"];
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];

	ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
	readerViewController.delegate = self;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:readerViewController];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}
```

#### Alternative usage

You can also use ReaderViewController as a subview of a normal UIViewController. This requires extra, slightly obscure setup, so is not the recommended method. With that being said, here's an example:

```objectivec

-(void)addReaderToView:(id)sender {
   
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mydocument" ofType:@"pdf"];
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];

	_readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
	_readerViewController.delegate = self;
    _readerViewController.remoteNavigationItem = self.navigationItem;
    _readerViewController.remoteNavigationController = self.navigationController;

    [self.view addSubview:_readerViewController.view];
	
}

// IMPORTANT:
// You will need to notify ReaderViewController when the view state changes.

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_readerViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_readerViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_readerViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_readerViewController viewDidDisappear:animated];
}

```


### Acknowledgements

This is a fork of Julius Oklamcak's [Reader](https://github.com/vfr/Reader) project, so full credit to him for the base work.

### License

This code has been made available under the MIT License.
