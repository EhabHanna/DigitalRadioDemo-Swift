# DigitalRadioDemo-Swift
This is the same digital radio demo project except in swift. 
I figured what better way to practice swift than to translate an already implemented project. 
Also since chances are someone might request something like this in the future; behold I can do it


The demo will begin with a splash screen that will load and parse an
onAir document from a local file then will move to a new screen to
display a table view with 2 sections that show the rendered items.

## Getting started
Since I did not have much to go on, I have made a few assumptions about
how the app will behave.

1. Application will first fetch "OnAir" XML Data from url 
2. Application will save XML data to file for later 
3. Application will wait 1 second before showing another view with rendered data in table

on subsequent launches the application will load from saved XML file,
this is in order to save time or in case the device is offline.

## Test Cases

There are a few XCTests included with the project, however no UI tests.

### Testing the model parsing

#### Item initialization tests
1. Check if items will be initialized with values passed in Dictionaries.
2. Check if custom fields are initialized with values passes in dictionary

#### Parser initialization tests
1. Check trivial initializations with nil files or strings, empty XMLs and invalid XMLs
2. Check initialization from XML file and from raw XML string
3. Check if item values are parsed correctly from XML
4. Check if item Custom fields are parsed correctly from XML

## Authors

* **Ehab Asaad Hanna** - [Git Hub Page](https://github.com/EhabHanna)

## Acknowledgments

* Translated the LazyTableImages example provided by Apple for item image download - [LazyTableImages](https://developer.apple.com/library/content/samplecode/LazyTableImages/Introduction/Intro.html)
* Used Ashley Mills' Reacability because translating it my self would have been too far off topic - [Reachability](https://github.com/ashleymills/Reachability.swift)
