//
//  Share.js
//  Post To Groups
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

var Share = function() {};

Share.prototype = {
run: function(arguments) {
    arguments.completionFunction({
                                 "URL": document.URL,
                                 "selectedText": document.getSelection().toString(),
                                 "title": document.title
                                 });
},
finalize: function(arguments) {
    // alert shared!
}
};

var ExtensionPreprocessingJS = new Share
