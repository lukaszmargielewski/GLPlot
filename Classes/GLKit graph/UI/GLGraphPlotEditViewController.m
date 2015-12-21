//
//  GLGraphPlotEditViewController.m
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import "GLGraphPlotEditViewController.h"
#import "UITextFieldCell.h"
#import "UITextViewCell.h"

@interface GLGraphPlotEditViewController ()

@end

@implementation GLGraphPlotEditViewController{


    NSMutableDictionary *_plotDictionary;
}


-(void)viewDidLoad{

    [super viewDidLoad];
    
    _plotDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (self.plot) {

        [_plotDictionary setValue:_plot.name forKey:@"name"];
        [_plotDictionary setValue:_plot.title forKey:@"title"];
        [_plotDictionary setValue:_plot.text forKey:@"text"];
        [_plotDictionary setValue:_plot.extra_info forKey:@"extra_info"];
        [_plotDictionary setValue:[NSString stringWithFormat:@"%i", _plot.tag] forKey:@"tag"];
        
        UIColor *color = [UIColor colorWithRed:_plot.color.x green:_plot.color.y blue:_plot.color.z alpha:_plot.color.w];
        [_plotDictionary setValue:color forKey:@"color"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 320, 40);
        [button setTitle:@"Delete" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
 
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem = cancelItem;
}
-(void)incorporateEditedData:(NSDictionary *)editedData topGLPlot:(GLPlot *)plot{

    plot.title      = editedData[@"title"];
    plot.text       = editedData[@"text"];
    plot.extra_info = editedData[@"extra_info"];
    plot.tag        = [editedData[@"tag"] intValue];
    
    UIColor *color = editedData[@"color"];
    if (color) {
        
        const CGFloat *comps = CGColorGetComponents(color.CGColor);
        plot.color = GLVector4DMake(comps[0], comps[1], comps[2], comps[3]);
        
    }

}
-(IBAction)save:(id)sender{

    if (!_plotDictionary[@"name"]) {
        UIAlertView *alrtview = [[UIAlertView alloc] initWithTitle:@"name is obligatory" message:@"GLPlot must have a name" delegate:nil cancelButtonTitle:@"Understood!" otherButtonTitles:nil];
        [alrtview show];
        return;
    }
    
    if (self.plot) {
    
        [self incorporateEditedData:_plotDictionary topGLPlot:_plot];
        [_delegate GLGraphPlotEditViewController:self didSavePlot:_plot];
    }else{
    
       
        
        NSLog(@"Creating new plot from temp data: %@", _plotDictionary);
        
        GLPlot *newPlot = [[GLPlot alloc] initWithName:_plotDictionary[@"name"]];
        [self incorporateEditedData:_plotDictionary topGLPlot:newPlot];
        [_delegate GLGraphPlotEditViewController:self didCreateNewPlot:newPlot];
    }
    
}
-(IBAction)cancel:(id)sender{
    
    [_delegate GLGraphPlotEditViewControllerDidCancel:self];
}
-(void)delete:(id)sender{

    [_delegate GLGraphPlotEditViewController:self willDeletePlot:_plot];
    [_delegate GLGraphPlotEditViewController:self didDeletePlot:_plot];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return GLPlotEditingSectionsCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    switch (section) {
        
        case GLPlotEditingSectionMain: // name, title, tag, color
                return GLPlotEditingSectionMainItemsCount;
            break;
            
            case GLPlotEditingSectionReadOnly:
                return GLPlotEditingSectionReadOnlyItemsCount;
            break;
            
        default:
            break;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{return 50;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {
        case GLPlotEditingSectionText:
        case GLPlotEditingSectionExtraOptionalInfo:
            return 120;
            break;
            
        default:
            break;
    }
    return 40;

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 40)];
    
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    
    NSString *text = nil;
    
    switch (section) {
            
        case GLPlotEditingSectionMain:
            text = @"Title, name, tag & color:";
            break;
        case GLPlotEditingSectionReadOnly:
            text = @"Read only info:";
            break;
        case GLPlotEditingSectionText:
            text = @"Description tet (optional):";
            break;
            
        case GLPlotEditingSectionExtraOptionalInfo:
            text = @"Extra optional info:";
            break;
            
        default:
            break;
    }
    
    label.text = text;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *NamesCellID        = @"NamesCellID";
    static NSString *NormalCellID   = @"NormalCellID";
    static NSString *TextsCellID        = @"TextsCellID";
    static NSString *ColorCellID        = @"ColorCellID";
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITextFieldCell *cell = nil;
    
    switch (section) {
            
        case GLPlotEditingSectionMain:
        {
    
            switch (row) {
                case GLPlotEditingSectionMainItemColor:
                {
                
                
                    cell = [tableView dequeueReusableCellWithIdentifier:ColorCellID];
                    if (!cell) {
                        cell = (UITextFieldCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ColorCellID];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
                        v.layer.borderWidth = 1.0;
                        v.backgroundColor = [UIColor clearColor];
                        cell.accessoryView = v;
                    }
                    
                    
                    UIColor *color = [_plotDictionary valueForKey:@"color"];
                    cell.accessoryView.backgroundColor = (color) ? color : [UIColor clearColor];
                    cell.textLabel.text = @"Color";
                    
                }
                    break;
                    
                default:
                {
                
                    cell = [tableView dequeueReusableCellWithIdentifier:NamesCellID];
                    if (!cell) {
                        cell = (UITextFieldCell *)[[UITextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NamesCellID];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textField.keyboardType = UIKeyboardTypeDefault;
                        cell.textField.delegate = self;
                    }
                    
                    NSString *placeholder = nil;
                    NSString *value = nil;
                    
                    switch (indexPath.row) {
                        case GLPlotEditingSectionMainItemName:
                            placeholder = @"Name:";
                            value = _plotDictionary[@"name"];
                            break;
                        case GLPlotEditingSectionMainItemTitle:
                            placeholder = @"Title:";
                            value = _plotDictionary[@"title"];
                            break;
                        case GLPlotEditingSectionMainItemTag:
                            placeholder = @"Tag:";
                            value = _plotDictionary[@"tag"];
                            break;
                        default:
                            break;
                    }
                    cell.textField.placeholder = placeholder;
                    cell.textField.text = value;
                
                }
                    break;
            }
            
                                     
        }
        break;
            
        case GLPlotEditingSectionReadOnly:
        {
        
            cell = [tableView dequeueReusableCellWithIdentifier:NormalCellID];
            if (!cell) {
                cell = (UITextFieldCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NormalCellID];
            }
            
            switch (row) {
                case GLPlotEditingSectionReadOnlyItemIdentifier:
                {
                
                    cell.textLabel.text = @"Identifier:";
                    cell.detailTextLabel.text = self.plot.identifier_string;
                }
                    break;
                case GLPlotEditingSectionReadOnlyItemVerticesCount:
                {
                    cell.textLabel.text = @"Points count:";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", self.plot.verticesCount];
                }
                    break;
                    
                default:
                    break;
            }
        }
        break;
            
        case GLPlotEditingSectionText:
        {
            
            cell = [tableView dequeueReusableCellWithIdentifier:TextsCellID];
            if (!cell) {
                UITextViewCell *ccc = [[UITextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextsCellID];
                ccc.textView.delegate = self;
                cell = (UITextFieldCell *)ccc;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = _plotDictionary[@"text"];
            
        }
        break;
            
        case GLPlotEditingSectionExtraOptionalInfo:
        {
        
            cell = [tableView dequeueReusableCellWithIdentifier:TextsCellID];
            if (!cell) {
                UITextViewCell *ccc = [[UITextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextsCellID];
                ccc.textView.delegate = self;
                cell = (UITextFieldCell *)ccc;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = _plotDictionary[@"extra_info"];
        }
        break;
        
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - text changes:

-(UITableViewCell *)cellForControll:(UIView *)controllView{

    UITableViewCell *cell = (UITableViewCell *)[controllView superview];
    
    while (cell != nil && ![cell isKindOfClass:[UITableViewCell class]]) {
        
        cell = (UITableViewCell *)cell.superview;
    }
    
    return cell;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString * text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    UITableViewCell *cell = [self cellForControll:textField];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case GLPlotEditingSectionMain:
        {
        
            switch (row) {
                    case GLPlotEditingSectionMainItemName:
                    _plotDictionary[@"name"] = text;
                    break;
                case GLPlotEditingSectionMainItemTitle:
                    _plotDictionary[@"title"] = text;
                    break;
                case GLPlotEditingSectionMainItemTag:
                    _plotDictionary[@"tag"] = text;
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{

    NSString * text = textView.text;
    
    UITableViewCell *cell = [self cellForControll:textView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    
    switch (section) {
        case GLPlotEditingSectionText:
        {
            _plotDictionary[@"text"] = text;
        }
            break;
        case GLPlotEditingSectionExtraOptionalInfo:
        {
            _plotDictionary[@"extra_info"] = text;
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark - Allow selecting color cell:
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == GLPlotEditingSectionMain || indexPath.row ==GLPlotEditingSectionMainItemColor) {
        
        return indexPath;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


   if (indexPath.section == GLPlotEditingSectionMain || indexPath.row ==GLPlotEditingSectionMainItemColor) {
       
        ColorPickerViewController *cpvc = [[ColorPickerViewController alloc] init];
       cpvc.color = _plotDictionary[@"color"];
            cpvc.delegate = self;
            [self.navigationController pushViewController:cpvc animated:YES];
            
        }
    
}

#pragma mark - Color picker:
-(void)ColorPickerViewController:(ColorPickerViewController *)controller didFinishWithColor:(UIColor *)color{

    _plotDictionary[@"color"] = color;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:GLPlotEditingSectionMainItemColor inSection:GLPlotEditingSectionMain]] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController popToViewController:self animated:YES];
    
}
-(void)ColorPickerViewControllerDidCancel:(ColorPickerViewController *)controller{

    [self.navigationController popToViewController:self animated:YES];
}
@end
