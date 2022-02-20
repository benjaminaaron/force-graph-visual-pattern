# force-graph-visual-pattern

You can view it live [here](https://benjaminaaron.github.io/force-graph-visual-pattern/). You can zoom and pan, but that's about it. The logo will keep unfolding and stretching until eternity, at an increasingly boring pace. To reset it, you have to reload the page.

## Background

I developed this workflow to have a neat animated graph-looking logo-visualization for the cover slide of a presentation about knowledge graphs. My original idea was to do something in 3D where only from a certain angle you would see a logo appear in the 3D space 🤓 From there I thought it'd be cool to use the [3d-force-graph](https://github.com/vasturiano/3d-force-graph) library to see if its possible to re-create specific predefined shapes just based on the info of what nodes are connected to which other ones, no information about positions. Because I didn't figure out an easy way (yet) how to extrude a logo into 3D and get points on the surface (Blender, Three.js?) I settled on using Processing and 2D [force-graph](https://github.com/vasturiano/force-graph) (for now).

## Workflow

Place your logo/text/pattern in `sketch/`, open `sketch.pde` in [Processing](https://processing.org/), change the dimensions and the filename and run it. It looks at each pixel of your input image and creates nodes and edges in two categories (= inside or outside the logo), based on the color of the pixel: white or not-white. It will place a `generated-data.js` in `js/`. Also it will "show" you what it has done. For the example logo (called "logo" 😉) it looks like this: 

![Screenshot 2022-02-20 at 16 15 21](https://user-images.githubusercontent.com/5141792/154849672-35c18b97-0c54-486f-bbe1-f81490ba054d.png)

There are lots of parameters in the code to experiment around with. 

The next step is to open `index.html` in the browser. The JS code will pick up the nodes/edges data from the generated file and do it's physics engine thing. I left various experimental code snippets outcommented in there for others to play around with.

I haven't looked into how to control the physics engine more in a way to get a more directed kind of unfolding of the pattern. With the logo I did all this for, it went quite alright. It can happen though, that your logo unfolds akwardly bent or mirrored etc. You can change around on the pipeline by changing the dimensions of the input image or the grid size parameters etc., maybe in another configuration it unfolds more nicely readable.

![Screenshot 2022-02-20 at 17 38 31](https://user-images.githubusercontent.com/5141792/154853575-88aaaaf2-1199-465a-a396-d914e334b5ff.png)

## Post-processing

To turn this into an animated GIF, I added mouse move and resize listeners so that I could resize the browser window to a desired size and position my cursor exactly in the middle. The latter is important because otherwise the manual zooming in and out with the scroll wheel / touchpad isn't nicely centered. You can also try to zoom and pan the viewport computationally, but I had no luck with that and went with manually. I am on a Mac, so I used Cursorcerer to hide the cursor in the screenrecording with QuickTime. Then I increased the speed in the 2nd half of the video in iMovie and appended the reverse animation to have a forward/backward looping animation. Finally I used Gifski to create a GIF from it.
