//
//  GLGraphViewSelectionSttingsViewController.m
//  Accel
//
//  Created by Lukasz Margielewski on 17/08/14.
//
//

#import "GLGraphViewSelectionSettingsViewController.h"

@interface GLGraphViewSelectionSettingsViewController ()

@end

@implementation GLGraphViewSelectionSettingsViewController{

    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *addButton;
    
    GLGraphViewSelection *_editingSelection;
    
}
@synthesize selectionsPath = _selectionsPath;

 static NSString *cellId = @"SeletionCellID";

-(void)dealloc{

    [self save];
}
-(void)save{

    [NSKeyedArchiver archiveRootObject:self.selections toFile:self.selectionsPath];
    
}
-(NSString *)selectionsPath{

    if (!_selectionsPath) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        
        _selectionsPath = [documentsDirectory stringByAppendingPathComponent:@"graph_selections.selections"];

    }
    return _selectionsPath;
}
+(GLGraphViewSelection *)defaultSelection{

    GLGraphViewSelection *selectionDefault = [[GLGraphViewSelection alloc] init];
    selectionDefault.name = @"Default";
    selectionDefault.machine_name = @"default";
    selectionDefault.selectionId = @(0);
    selectionDefault.size = CGSizeMake(0, 0);
    
    return selectionDefault;
    
}
-(NSMutableArray *)selections{

    if (!_selections) {
        _selections =  [NSKeyedUnarchiver unarchiveObjectWithFile:self.selectionsPath];
        
        if (!_selections || !_selections.count) {
            _selections = [[NSMutableArray alloc] initWithCapacity:10];
            
            GLGraphViewSelection *selectionDefault = [GLGraphViewSelectionSettingsViewController defaultSelection];
            [_selections addObject:selectionDefault];
        }
    }
    return _selections;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    //doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Use selected" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setRightBarButtonItems:@[addButton/*, doneButton*/]];
    
    
    self.title = @"Selections";
}

-(IBAction)done:(id)sender{

   
}

-(IBAction)cancel:(id)sender{

    [_delegate GLGraphViewSelectionSettingsViewControllerViewControllerDiDCancel:self];
    
}

-(IBAction)add:(id)sender{
    

    GLGraphViewSelection *selectionNew = [[GLGraphViewSelection alloc] init];
    selectionNew.name = @"Just added (edit)";
    selectionNew.selectionId = [NSNumber numberWithLong:(long)[[NSDate date] timeIntervalSince1970]];
    selectionNew.size = CGSizeMake(0, 0);
    [_selections insertObject:selectionNew atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    
    
}


-(CGSize)contentSizeForViewInPopover{return CGSizeMake(320, 500);}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.selections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Configure the cell...

    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 60, 30);
        [button addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        
    }
    
    
    GLGraphViewSelection *selection = [self.selections objectAtIndex:indexPath.row];
    
    cell.textLabel.font = (self.selection && [selection.selectionId longLongValue] == [self.selection.selectionId longLongValue]) ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = (selection.color) ? selection.color : [UIColor blackColor];
    cell.textLabel.text = selection.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"size: %@", NSStringFromCGSize(selection.size)];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.selection = [self.selections objectAtIndex:indexPath.row];
    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
     [_delegate GLGraphViewSelectionSettingsViewControllerViewController:self didFinishWithSelection:self.selection];
    
}
-(IBAction)edit:(UIButton *)sender{

    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    
    while (cell != nil && ![cell isKindOfClass:[UITableViewCell class]]) {
        
        cell = (UITableViewCell *)cell.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        
        _editingSelection = [self.selections objectAtIndex:indexPath.row];
        GLGraphSelectionEditViewController *evc = [[GLGraphSelectionEditViewController alloc] init];
        evc.selection = _editingSelection;
        evc.delegate = self;
        [self.navigationController pushViewController:evc animated:YES];
        
    }
}
-(void)GLGraphSelectionEditViewController:(GLGraphSelectionEditViewController *)controller didSaveSelection:(GLGraphViewSelection *)selection{

    NSLog(@"Save selection: %@",selection.name);
    NSUInteger index = [_selections indexOfObject:_editingSelection];
    [_selections replaceObjectAtIndex:index withObject:selection];
    [self save];
    // Reload appropriate row:
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self.navigationController popToViewController:self animated:YES];
}
-(void)GLGraphSelectionEditViewControllerDidCancel:(GLGraphSelectionEditViewController *)controller{

    [self.navigationController popToViewController:self animated:YES];
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GLGraphViewSelection *selection = [self.selections objectAtIndex:indexPath.row];
    
    return (![selection.machine_name isEqualToString:@"default"]); //  Default and MUST never be deleted.
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
 
        [_selections removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
