//
//  ClassDumpTests.m
//  
//
//  Created by JH on 2024/5/31.
//

#import <XCTest/XCTest.h>
#import <ClassDump.h>

@interface ClassDumpTests : XCTestCase

@end

@implementation ClassDumpTests

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    [[CDClassDumpManager sharedManager] performClassDumpOnFile:@"/Users/jh/Library/Developer/Xcode/DerivedData/TestFramework-gflpuuagpsxersallkcsqvldokke/Build/Products/Debug/TestFramework.framework/Versions/A/TestFramework" toFolder:@"/Users/jh/Library/Developer/Xcode/DerivedData/TestFramework-gflpuuagpsxersallkcsqvldokke/Build/Products/Debug/TestFramework.framework/Versions/A" error:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
