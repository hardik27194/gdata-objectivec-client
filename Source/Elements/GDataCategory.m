/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataCategory.m
//

#define GDATACATEGORY_DEFINE_GLOBALS 1
#import "GDataCategory.h"

static NSString* const kSchemeAttr = @"scheme";
static NSString* const kTermAttr = @"term";
static NSString* const kLabelAttr = @"label";
static NSString* const kLangAttr = @"xml:lang";

@implementation GDataCategory
// for categories, like
//  <category scheme="http://schemas.google.com/g/2005#kind"
//        term="http://schemas.google.com/g/2005#event"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtom; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPrefix; }
+ (NSString *)extensionElementLocalName { return @"category"; }

+ (GDataCategory *)categoryWithScheme:(NSString *)scheme
                                 term:(NSString *)term {
  GDataCategory* obj = [[[GDataCategory alloc] init] autorelease];
  [obj setScheme:scheme];
  [obj setTerm:term];
  return obj;
}

+ (GDataCategory *)categoryWithLabel:(NSString *)label {
  
  NSString *term = [NSString stringWithFormat:@"%@#%@",
    kGDataCategoryLabelScheme, label];
  
  GDataCategory *obj = [self categoryWithScheme:kGDataCategoryLabelScheme
                                           term:term];
  [obj setLabel:label];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects:
                    kSchemeAttr, kTermAttr, kLabelAttr, kLangAttr, nil];
  
  // we don't declare xml:lang since we'll be excluding it from
  // the isEqual: comparison
  
  [self addLocalAttributeDeclarations:attrs];    
}

- (NSArray *)attributesIgnoredForEquality {
  
  // per Category.java: this should exclude label and labelLang,
  // but the GMail provider is generating categories which
  // have identical terms but unique labels, so we need to compare
  // label values as well, though not xml:lang
  
  return [NSArray arrayWithObject:kLangAttr];
}

// should we override hash function like Java does?

- (NSString *)scheme {
  return [self stringValueForAttribute:kSchemeAttr];
}

- (void)setScheme:(NSString *)str {
  [self setStringValue:str forAttribute:kSchemeAttr];
}

- (NSString *)term {
  return [self stringValueForAttribute:kTermAttr];
}

- (void)setTerm:(NSString *)str {
  [self setStringValue:str forAttribute:kTermAttr];
}

- (NSString *)label {
  return [self stringValueForAttribute:kLabelAttr];
}

- (void)setLabel:(NSString *)str {
  [self setStringValue:str forAttribute:kLabelAttr];
}

- (NSString *)labelLang {
  return [self stringValueForAttribute:kLangAttr];
}

- (void)setLabelLang:(NSString *)str {
  [self setStringValue:str forAttribute:kLangAttr];
}

@end

@implementation NSArray(GDataCategoryArray)

// return all categories with the specified scheme
- (NSArray *)categoriesWithScheme:(NSString *)scheme {
  
  NSMutableArray *matches = [NSMutableArray array];
  NSEnumerator *enumerator = [self objectEnumerator];
  GDataCategory *category;
  
  while ((category = [enumerator nextObject]) != nil) {
    NSString *currScheme = [category scheme];
    if (currScheme != nil && [currScheme isEqual:scheme]) {
      
      [matches addObject:category];
    }
  }
  return matches;
}

// return all categories whose schemes have the specified prefix
- (NSArray *)categoriesWithSchemePrefix:(NSString *)prefix {
  NSMutableArray *matches = [NSMutableArray array];
  NSEnumerator *enumerator = [self objectEnumerator];
  GDataCategory *category;
  
  while ((category = [enumerator nextObject]) != nil) {
    NSString *scheme = [category scheme];
    if (scheme != nil && [scheme hasPrefix:prefix]) {
      [matches addObject:category];
    }
  }
  return matches;
}

- (NSArray *)categoryLabels {
  
  NSMutableArray *labels = [NSMutableArray array];
  NSEnumerator *enumerator = [self objectEnumerator];
  GDataCategory *category;
  
  while ((category = [enumerator nextObject]) != nil) {
    NSString *label = [category label];
    if (label != nil && ![labels containsObject:label]) {
      [labels addObject:label];
    }
  }
  return labels;
}

- (BOOL)containsCategoryWithLabel:(NSString *)label {
  GDataCategory *category = [GDataCategory categoryWithLabel:label];
  
  BOOL hasLabel = [self containsObject:category];
  return hasLabel;
}
@end
