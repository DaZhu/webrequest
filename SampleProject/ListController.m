#import "ListController.h"
#import "SMXMLDocument.h"

@interface ListController ()

@property (nonatomic, retain) SMWebRequest *request;
@property (nonatomic, retain) NSArray *items;

@end


@implementation ListController

@synthesize request, items;

// it's a good idea for controllers to retain the requests they create for easy cancellation.
- (void)setRequest:(SMWebRequest *)value {
	[request removeTarget:self]; // will cancel the request if it is currently loading.
	[request release];
	
	request = [value retain];
	[request addTarget:self action:@selector(requestComplete:) forRequestEvents:SMWebRequestEventComplete];
}

- (id)initListController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = @"Hacker News";
	}
	return self;
}

- (void)dealloc {
	self.request = nil;
	self.items = nil;
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	if (!items) {
		self.request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/rss"] delegate:self context:nil];
		[request start];
	}
}

- (void)requestComplete:(NSArray *)theItems {
	self.items = theItems;
	[self.tableView reloadData];
}

// This method is called on a background thread. Don't touch your instance members!
- (id)webRequest:(SMWebRequest *)webRequest resultObjectForData:(NSData *)data context:(id)context {
	
	SMXMLDocument *document = [SMXMLDocument documentWithData:data];
	
	return [[document.root childNamed:@"channel"] childrenNamed:@"item"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ItemTableViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	
	cell.textLabel.text = [[items objectAtIndex:indexPath.row] childNamed:@"title"].value;
	return cell;
}
		

@end
