# MetalUI

This is a very early work in progress at an attempt at a Metal native UI framework that is somewhat like SwiftUI but optimised for rendering directly to Metal and easy to integrate in a game. I'm using it in a starship combat game.

It uses instance rendering and some of the changes to how SwiftUI does things are about trying to maintain a constant sized instance buffer. So for example their is a .visibility modifier that you can use with conditions rather than inserting or removing elements (though that will be supported). When tree diffing is implemented (its not yet) the idea is to only update the required parts of the instance buffer.

I've been learning more about Swift as I go so definitely a work in progress. Been fascinating.
