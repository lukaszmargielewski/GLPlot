//
//  GLPlotDynamic.m
//  Accel
//
//  Created by Lukasz Margielewski on 11/04/14.
//
//

#import "GLPlot.h"
#import "GLGraph.h"
#import "GLProgram.h"

/**
 
 Following constants are for simple culling techinque = segmentation:
 
 1. We will store x position wirh index for every kVertSegmentSize postion. this Will crete so called segments.
 2. When visible rectangle is updated, we will scan what segments are visible, using fast binary seach algorhitm.
 3. We will draw only trangles which belongs to the visible segments.
 
 */

#define kVertsPerSegment        500
#define kSegmentsReserveSize    100
#define kVertSaveSize           1500

#define kGLPlotNameKey @"name"
#define kGLPlotDataFileNameKey @"data_file_name"

#include <vector>
using namespace std;


typedef struct GLPlotHeader{
    
    char name               [kGLPlotMaximumNameLenght];
    char identifier_string  [kGLPlotMaximumIdentifierStringLenght];
    char title              [kGLPlotMaximumTitleLenght];
    char text               [kGLPlotMaximumTextLenght];
    char extra_info         [kGLPlotMaximumExtraInfoLenght];

    GLVector4D          color;
    int                 tag;
    
}GLPlotHeader;



@implementation GLPlot{
    
    NSMutableArray *_segments;
    
    NSFileHandle *_fileHanleWrite;
    NSFileHandle *_fileHanleRead;
    
    GLsizei _firstVisibleSegmentIndex;
    GLsizei _lastVisibleSegmentIndex;

    BOOL _headerNeedsSave;
    
}
@synthesize filePath = _filePath;

-(void)dealloc{

    [_fileHanleWrite closeFile];
    [_fileHanleRead closeFile];
}

-(id)initWithFilePath:(NSString *)filePath{
    
    self = [super init];
    
    if (self) {
        
        _filePath = filePath;
        [self commonInit];
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name{

    NSAssert(name != nil, @"GLPLot name must not be nil!");
    
    self = [super init];
    
    if (self) {
        
        self.name = name;
        
        NSDateFormatter *_df = [[NSDateFormatter alloc] init];
        _df.dateFormat = @"ddMMyyyy_HHmmss";
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", name, [_df stringFromDate:[NSDate date]]];
        _filePath = [[[GLPlot defaultStorageDirectory] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kGLPlotFileExtension];
        
        [self commonInit];
        
    }
    
    return self;
}
-(void)parseFileHeader{
    
    [_fileHanleRead seekToFileOffset:0];
    NSData *data = [_fileHanleRead readDataOfLength:sizeof(GLPlotHeader)];
    
    GLPlotHeader *header = (GLPlotHeader *)[data bytes];

    self.name           = [NSString stringWithUTF8String:header->name];
    self.title          = [NSString stringWithUTF8String:header->title];
    self.text           = [NSString stringWithUTF8String:header->text];
    self.extra_info     = [NSString stringWithUTF8String:header->extra_info];
    self.identifier_string = [NSString stringWithUTF8String:header->identifier_string];
    self.tag            = header->tag;
    self.color          = header->color;
    
    NSAssert(self.name != nil, @"GLPLot name not found in GLPlot file header!");
}
-(void)commonInit{

    _lineMode = GL_LINE_STRIP;
    
    _firstVisibleSegmentIndex = _lastVisibleSegmentIndex = 0;
    _verticesCount      = 0;
    _segments           = [[NSMutableArray alloc] initWithCapacity:kSegmentsReserveSize];
    self.lineWidth      = 3;
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
    }
    _fileHanleRead      = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    _fileHanleWrite     = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    
    unsigned long long bytesAll     = [_fileHanleWrite seekToEndOfFile];
    unsigned long long bytesData    = (bytesAll >= sizeof(GLPlotHeader)) ? MAX(0, bytesAll - sizeof(GLPlotHeader)) : 0;
    
    if (bytesAll >= sizeof(GLPlotHeader)) {
        
        [self parseFileHeader];
        _headerNeedsSave = NO;
        
    }else{
    
        _headerNeedsSave = YES;
        
    }
    
    if (bytesData >= _bytesPerVertice) {
    
        [self reloadVerticesFromFile];
   
    }
}
-(id)init{

    NSAssert(NO, @"GLPlot init initialier not allowed - must use initWithName:(NSString *)name!");
    
    return nil;
}

-(void)reloadVerticesFromFile{

    // Loading from NSFileHandle to std::vector

    
    unsigned long long bytesAll     = [_fileHanleWrite seekToEndOfFile];
    unsigned long long bytesData    = MAX(0, bytesAll - sizeof(GLPlotHeader));
    
    if (bytesData < _bytesPerVertice) {
        return;
    }
    
    _verticesCount = ceil(bytesData / (float)_bytesPerVertice);
    unsigned long long segmentsCount = ceil((double)_verticesCount / (double)kVertsPerSegment);

    [self clear];
    
    
    //
    for (int i = 0; i < segmentsCount; i++) {
        
        GLVector2D *pointer = NULL;
        GLSegment *segment = _segments[i];
        
        //segment.vertices.assign(pointer, pointer + kVertsPerSegment);  // ??? How / if does it really work?
    }

     // Calling culling at the end should reload _vbos approriately for us:
    [self setNeedsCulling];
    
}
-(void)clear{
 
    _firstVisibleSegmentIndex = _lastVisibleSegmentIndex = 0;

    // TODO: Implement cleaning (remember GLPlotSegment needs help in releasing memory):

    
}

-(void)cull{

    [super cull];
    
    // We can only make x axis cull - should be good enought:


    int iterationsStart = 0;
    int iterationsEnd   = 0;
    
 
        // x visible start and end:
        CGFloat XWS   = CGRectGetMinX(_visibleRect);
        CGFloat XWE   = CGRectGetMaxX(_visibleRect);
        
        BOOL found;
        GLfloat xStart, xEnd;
        
        // Binary search visible segment indexes (iSS - index of start segment, iSE - index of end segment)
        _firstVisibleSegmentIndex = [self segmentIndexForClosestX:XWS found:found valueFound:xStart iterations:iterationsStart];
        _lastVisibleSegmentIndex = [self segmentIndexForClosestX:XWE found:found valueFound:xEnd iterations:iterationsEnd];
    //NSLog(@"%@ culled from: %i, to: %i, visible: %i", self.name, _firstVisibleSegmentIndex, _lastVisibleSegmentIndex, (_lastVisibleSegmentIndex - _firstVisibleSegmentIndex) + 1);
}

-(GLsizei)segmentIndexForClosestX:(GLfloat)x found:(BOOL &)found valueFound:(GLfloat &)valueFound iterations:(int &)iterations{

    // Segment indexes start and end:
    GLsizei   low    = 0;
    GLsizei   high   = _segments.count - 1;
    
    GLsizei   mid    = (low + high) / 2.0;
    
    found = NO;

    iterations = 0;
    
    //NSLog(@"----");
    while (low <= high) {
       // NSLog(@"it: %i, low: %lld, high: %lld, mid: %lld", iterations, low, high, mid);
        GLSegment *seg = _segments[mid];
        valueFound  = seg.firstVector.x;
        
        if (valueFound < x) {
            
            low = mid + 1;
            
        }else if (valueFound > x){
            
            high = mid - 1;
        
        }else{
        
            found = YES;
            break;
        }
        
        mid    = (low + high) / 2.0;
        iterations++;
        
    }
    //NSLog(@"----");
    
    return mid;
    
}

#pragma mark - render override:

-(void)renderInGraph:(GLGraph *)graph{
    
    int segCount = _segments.count;
    
    if (!_visible || _firstVisibleSegmentIndex >= segCount)return;
    
    GLProgram *shader = graph.shader;
    [graph.shader use];
    
    // Setting color:
    GLint cui = [shader uniformIndex:kColorUniformName];
    GLint ati = [shader attributeIndex:kPositionAttributeName];
    
    glEnableVertexAttribArray(ati);
    glEnableVertexAttribArray(cui);
    

    
    GLfloat lineWidth = self.lineWidth;
    
    glLineWidth(lineWidth);GL_ERROR_CHECK_DEBUG();
    
    GLVector4D color  = self.color;
    
    for (int i = _firstVisibleSegmentIndex; i <= _lastVisibleSegmentIndex; i++) {
        
        GLSegment *segment = _segments[i];
        unsigned long vCount = segment.vertsCount;
        if (vCount == 0)return;
        
        /*
        GLVector4D color = (i % 2) ?  GLVector4DMake(0, 1, 0, 1) : GLVector4DMake(0, 0, 1, 1);
        if (i == segCount - 1) {
            color = GLVector4DMake(1, 0, 0, 1);
        }
        */
        // !!!: Always bind buffer 1st to avoid wasiting 1 days!!!!!
        glBindBuffer(GL_ARRAY_BUFFER, segment.vbo);GL_ERROR_CHECK_DEBUG();
        
        glUniform4f(cui, color.x, color.y, color.z, color.w);GL_ERROR_CHECK_DEBUG();
        glVertexAttribPointer(ati, 2, GL_FLOAT, GL_FALSE, 0, 0);GL_ERROR_CHECK_DEBUG();
        glDrawArrays(_lineMode, 0, vCount);GL_ERROR_CHECK_DEBUG();
     
    }
    
}
#pragma mark - Setting Plot Data:

-(BOOL)addVector2D:(GLVector2D)vector2{
    
    GLSegment *segment = [_segments lastObject];
    if (!segment) {
        segment = [[GLSegment alloc] initWithSize:kVertsPerSegment index:_segments.count];
        [_segments addObject:segment];
       
    }
    
    if (![segment addGLVector2D:vector2]) {
    
        GLVector2D lastVector = segment.lastVector;
        
        segment = [[GLSegment alloc] initWithSize:kVertsPerSegment index:_segments.count];

        //NSLog(@"Adding v pre: %.1f, %.1f and this: %.1f, %.1f", lastVector.x, lastVector.y, vector2.x, vector2.y);
        //NSLog(@"Added last v: %.3f, %.3f", lastVector.x, lastVector.y);
        [segment addGLVector2D:lastVector];
        [segment addGLVector2D:vector2];
        
        [_segments addObject:segment];
    }
    _verticesCount++;
    ///*
    // TODO: Save very now and then
    if (_verticesCount && _verticesCount % kVertSaveSize == 0) {

        //[self save];
    }
    //*/
    [self setNeedsCulling];
    return YES;
    
}

#pragma mark - Persistence:

-(void)setColor:(GLVector4D)color{

    [super setColor:color];
    _headerNeedsSave = YES;
}
-(void)setText:(NSString *)text{

    _text = text;
    _headerNeedsSave = YES;
}
-(void)setTitle:(NSString *)title{

    _title = title;
    _headerNeedsSave = YES;
}
-(void)setTag:(int)tag{

    [super setTag:tag];
    _headerNeedsSave = YES;
}
-(void)setExtra_info:(NSString *)extra_info{

    _extra_info = extra_info;
    _headerNeedsSave = YES;
}
-(void)setName:(NSString *)name{

    [super setName:name];
    _headerNeedsSave = YES;
}
-(unsigned long long)unsavedBytes{

    // Implement data saving:
    unsigned long long bytesInMemory        = _verticesCount * _bytesPerVertice;
    unsigned long long bytesAll     = [_fileHanleWrite seekToEndOfFile];
    unsigned long long bytesData    = (bytesAll >= sizeof(GLPlotHeader)) ? MAX(0, bytesAll - sizeof(GLPlotHeader)) : 0;
    
    
    return (bytesInMemory - bytesData);
    
    
}
-(void)save{
    
    // 1. Save header (if needed):
    
    if (_headerNeedsSave) {
        
        GLPlotHeader header;// = (GLPlotHeader *)malloc(sizeof(GLPlotHeader));
        
        strcpy(header.name, [[self.name substringToIndex:MIN(self.name.length, kGLPlotMaximumNameLenght)] cStringUsingEncoding:NSUTF8StringEncoding]);
        
        if (!self.identifier_string || !self.identifier_string.length) {
        
            self.identifier_string = [NSString stringWithFormat:@"%@_%.0f", self.name, [[NSDate date] timeIntervalSince1970]];
            strcpy(header.identifier_string, [[self.identifier_string substringToIndex:MIN(self.identifier_string.length, kGLPlotMaximumIdentifierStringLenght)] cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        if (self.title && self.title.length) {

            strcpy(header.title, [[self.title substringToIndex:MIN(self.title.length, kGLPlotMaximumTitleLenght)] cStringUsingEncoding:NSUTF8StringEncoding]);

        }else{
        
            header.title[0] = NULL;
        }
        
        if (self.text && self.text.length) {
            
            strcpy(header.text, [[self.text substringToIndex:MIN(self.text.length, kGLPlotMaximumTextLenght)] cStringUsingEncoding:NSUTF8StringEncoding]);
            
        }else{
        
            header.text[0] = NULL;
        }
        
        
        if (self.extra_info && self.extra_info.length) {
            
            strcpy(header.extra_info, [[self.extra_info substringToIndex:MIN(self.extra_info.length, kGLPlotMaximumExtraInfoLenght)] cStringUsingEncoding:NSUTF8StringEncoding]);
            
        }else{
            
            header.extra_info[0] = NULL;
        }
        
        header.color = self.color;
        header.tag = self.tag;

        NSData *data = [NSData dataWithBytesNoCopy:&header length:sizeof(GLPlotHeader) freeWhenDone:NO];
        [_fileHanleWrite seekToFileOffset:0];
        [_fileHanleWrite writeData:data];
        
        
        //free(header);
    }
    
    // 2. Save plot data:

    unsigned long long unsavedBytes = [self unsavedBytes];
    
    if (unsavedBytes) {
        
        //TODO: Implement data / vertices saving:
        return;
        GLVector2D *pointer = NULL;
        
        unsigned long long bytesAlreadySaved = [_fileHanleWrite seekToEndOfFile] - sizeof(GLPlotHeader);
        
        void *bytesStartAddress = &pointer[bytesAlreadySaved];
        
        NSData *data = [NSData dataWithBytesNoCopy:bytesStartAddress length:unsavedBytes freeWhenDone:NO];
        [_fileHanleWrite writeData:data];
        //NSLog(@"Written %llu bytes (already saved: %llu) to file: %@", unsavedBytes, bytesAlreadySaved, _filePath);
    }
    
    
}

+(NSString *)defaultStorageDirectory{

    static NSString *_directory = nil;
    
    if (!_directory) {
    
        _directory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"plots_data_directory"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL isDir = NO;
        
        if (![fm fileExistsAtPath:_directory isDirectory:&isDir] && !isDir) {
            NSError *error = nil;
            BOOL created = [fm createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:&error];
            NSAssert2(created && !error, @"Directory at path not created: %@\n Error: %@", _directory, error);
        }
        
        NSLog(@"GLPlot defaultStorageDirectory: %@",_directory);
    }
    
    return _directory;
}

@end
