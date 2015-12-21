//
//  GLGraphSelectionEditViewController.m
//  Accel
//
//  Created by Lukasz Margielewski on 19/08/14.
//
//

#import "GLGraphSelectionEditViewController.h"
#import "UITextFieldCell.h"
#import "GLGraphViewSelection.h"

@interface GLGraphSelectionEditViewController ()

@end

@implementation GLGraphSelectionEditViewController


-(void)viewDidLoad{

    [super viewDidLoad];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
 
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.leftBarButtonItem = cancelItem;
}
-(IBAction)save:(id)sender{

    [_delegate GLGraphSelectionEditViewController:self didSaveSelection:_selection];
}
-(IBAction)cancel:(id)sender{
    
    [_delegate GLGraphSelectionEditViewControllerDidCancel:self];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 4;
}
#define kSectionNames 0
#define kSectionType 1
#define kSectionSize 2
#define kSectionColor 3

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    switch (section) {
        
        case kSectionNames:
            return 2;
            break;
        
        case kSectionType:
            return GLGraphViewSelectionTypesCount;
            break;
        
        case kSectionSize:
            return 2;
            break;
        
        default:
            break;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{return 50;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{return 40;}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 40)];
    
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor lightGrayColor];
    
    NSString *text = nil;
    
    switch (section) {
            
        case kSectionNames:
            text = @"Names:";
            break;
            
        case kSectionType:
            text = @"Choose type:";
            break;
            
        case kSectionSize:
            text = @"Size (width & optional height)";
            break;
            
        default:
            break;
    }
    
    label.text = text;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *NamesCellID = @"NamesCellID";
    static NSString *TypesCellID = @"TypesCellID";
    static NSString *SizeCellID = @"SizeCellID";
    static NSString *ColorCellID = @"ColorCellID";
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITextFieldCell *cell = nil;
    
    switch (section) {
            
        case kSectionNames:
        {
    
            cell = [tableView dequeueReusableCellWithIdentifier:NamesCellID];
            if (!cell) {
                cell = (UITextFieldCell *)[[UITextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NamesCellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textField.keyboardType = UIKeyboardTypeDefault;
                cell.textField.delegate = self;
            }
            
            NSString *placeholder = (row == 0) ? @"Name" : @"machine_name";
            NSString *value = (row == 0) ? self.selection.name : self.selection.machine_name;
            
            cell.textField.placeholder = /*cell.textLabel.text = */placeholder;
            cell.textField.text = value;
                                     
        }
        break;
            
        case kSectionType:
        {
            
            cell = [tableView dequeueReusableCellWithIdentifier:TypesCellID];
            if (!cell) {
                cell = (UITextFieldCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TypesCellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            GLGraphViewSelectionType type = (GLGraphViewSelectionType)row;
            cell.textLabel.text = NSStringFromGLGraphViewSelectionType(type);
            cell.accessoryType = (type == _selection.type) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
            break;
            
        case kSectionSize:
        {
        
            cell = [tableView dequeueReusableCellWithIdentifier:SizeCellID];
            if (!cell) {
                cell = (UITextFieldCell *)[[UITextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SizeCellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
                cell.textField.textAlignment = NSTextAlignmentRight;
                cell.textField.delegate = self;
            }
            
            NSString *placeholder = (row == 0) ? @"Width" : @"Height";
            CGFloat value = (row == 0) ? self.selection.size.width : self.selection.size.height;
            NSString *valueString = [NSString stringWithFormat:@"%.1f", value];
            cell.textField.placeholder = /*cell.textLabel.text =*/ placeholder;
            cell.textField.text = valueString;
        }
            break;
        case kSectionColor:
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

            
            cell.accessoryView.backgroundColor = (_selection.color) ? _selection.color : [UIColor clearColor];
            cell.textLabel.text = @"Color";
            
        }
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString * text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    
    while (cell != nil && ![cell isKindOfClass:[UITableViewCell class]]) {
        
        cell = (UITableViewCell *)cell.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case kSectionNames:
        {
        
            switch (row) {
                case 0:
                    _selection.name = text;
                    break;
                case 1:
                    _selection.machine_name = text;
                    break;
                default:
                    break;
            }
        }
            break;
        case kSectionSize:
        {
            CGSize size = _selection.size;
            switch (row) {
                case 0:
                    size.width = [text floatValue];
                    break;
                case 1:
                    size.height = [text floatValue];
                    break;
                default:
                    break;
            }
            _selection.size = size;
        }
            break;
        default:
            break;
    }
    
    return YES;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == kSectionType || indexPath.section == kSectionColor) {
        
        return indexPath;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case kSectionType:
        {
        
            _selection.type = (GLGraphViewSelectionType)row;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
            
        case kSectionColor:
        {
            
            ColorPickerViewController *cpvc = [[ColorPickerViewController alloc] init];
            cpvc.color = _selection.color;
            cpvc.delegate = self;
            [self.navigationController pushViewController:cpvc animated:YES];
            
        }
            break;
            
        default:
            break;
    }
}
-(void)ColorPickerViewController:(ColorPickerViewController *)controller didFinishWithColor:(UIColor *)color{

    _selection.color = color;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionColor] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController popToViewController:self animated:YES];
    
}
-(void)ColorPickerViewControllerDidCancel:(ColorPickerViewController *)controller{

    [self.navigationController popToViewController:self animated:YES];
}
@end
