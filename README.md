Flex Capacitor Library
======

A library of resources for Flex projects (beta).

==A library of resources for Flex projects^beta^== <br/>
This library contains Flex controls, classes and utilities. The main feature of this library are the action effects classes (work in progress). Their goal is to take common Flex and AS3 code and wrap it up into an abstract reusable class and apply it in MXML. In other environments these have been similar to or known as contracts, interactions, behaviors, commands, tasks and so on ([http://www.flexcapacitor.com/examples/LibraryExamples/ examples demo]). Update 11/18/2014: Many more effects have been added since this example including database actions and more.<br/>

===Contents===<br/>
  * Webview - composes the StageWebView in a UIComponent 
  * Minimal Scroller - adds MacOSX style scroll bars
  * Mini Inspector - helps designers and developers design and develop and debug at runtime
  * Event Handler - adds event listener(s) to target(s) in MXML and runs actions on those events
  * Form classes - simplifies working with forms on the client and server 
  * Action Effects - common behaviors applied in MXML allowing synchronous behavior on asynchronous objects.<br/>


===Libraries===<br/>
There's two libraries, one general and one mobile. There are example projects for each (well, the general one so far). <br/>

*Main Library*<br/>
https://github.com/monkeypunch3/flexcapacitor/tree/master/MainLibrary<br/>
https://github.com/monkeypunch3/flexcapacitor/tree/master/MainLibraryExamples<br/>

*Examples*<br/>
https://github.com/monkeypunch3/flexcapacitor/tree/master/MainMobileLibrary<br/>
https://github.com/monkeypunch3/flexcapacitor/tree/master/MainMobileLibraryExamples<br/>

*Live Examples*<br/>
Here are some live examples of some of the effects in this library including sorting, filtering, browsing for files and loading files. Right click to view source.<br/>
http://www.flexcapacitor.com/examples/LibraryExamples<br/>
http://www.judahfrangipane.com/examples/uigraphics<br/>
<br/>

===Action Effects===<br/>
The action effects are the main attraction here. A few lines of MXML code can replace millions of lines of code (ed. - it's all relative). Below is example code for sorting and filtering an array collection:<br/>

{{{
      
     <fx:Declarations>
    
        <!-- SORT BY NAME -->
        <handlers:EventHandler eventName="creationComplete" >
            <data:SortCollection target="{arrayCollection}"  />
        </handlers:EventHandler>
        
        
        <!-- FILTER -->
        <handlers:EventHandler eventName="change" target="{filterInput}">
            <data:FilterCollection target="{arrayCollection}" 
                                   source="{filterInput}" 
                                   sourcePropertyName="text"/>
        </handlers:EventHandler>
    </fx:Declarations>

    <s:HGroup>
        <s:TextInput id="filterInput" width="80%" prompt="Search"/>
        <s:Button id="searchButton" label="search"/>
    </s:HGroup>
}}}
<br/>

In the code above the array collection is sorted on creation complete of the document. The array collection is filtered when the user types text into the search text input. The code above uses the EventHandler class to add event handlers via MXML and run the sequence of actions it contains. A live example is shown on the examples page. A list of the effects are here, https://github.com/monkeypunch3/flexcapacitor/tree/master/MainLibrary/src/com/flexcapacitor/effects.<br/>


===Action Effects Examples=== <br/>
Here are some initial examples including sorting, filtering, browsing for files and loading files. Right click to view source. 
[http://www.flexcapacitor.com/examples/LibraryExamples/ Action Effects Examples]<br/>


===Action Effects Benefits=== <br/>
  * Easy to read and apply - Easy to write MXML (XML) and set options easily. Same benefits as other MXML components and classes.
  * Less typing - You don't have to type the same things you type all the time.
  * Less error prone - Parameters and options are set through typed properties preventing incorrect values. Code is written once, not every time. Only the options change. 
  * Interactive error messages - Parameter values and options are validated at runtime and generate context sensitive error messages.
  * Human readable - Understandable names such as Open Camera Roll, Sort Collection, etc
  * Linear - Can be run in sequence, pause and resume. For example, a service call action can run and then wait to continue until after a result is received. No event listeners required.  
  * Non-Linear - Can branch to other sequences. For example, if working on an app that can run on mobile or browser you can check if you are on a mobile device and open the camera roll (OpenCameraRoll action) or if in the browser open a browse dialog (OpenBrowserDialog action) or run another sequence of actions. 
  * Easy to test - Can easily create tests. <br/>
<br/>

