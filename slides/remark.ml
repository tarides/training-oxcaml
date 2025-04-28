let header title = Printf.sprintf {html|
<!DOCTYPE html>
<html>
  <head>
    <title>%s</title>
    <meta charset="utf-8">
    <style>
      @import url(https://fonts.googleapis.com/css?family=Fira+Code);
      @import url(https://fonts.googleapis.com/css?family=Roboto+Mono);
      @import url(https://fonts.googleapis.com/css?family=Inconsolata);
      @font-face {
          font-family: 'DaxlinePro';
          src: url('DaxlinePro-Regular.otf') format('opentype');
          font-weight: normal;
          font-style: normal;
          font-display: swap;
      }
      @font-face {
          font-family: 'DaxlinePro';
          src: url('DaxlinePro-Bold.otf') format('opentype');
          font-weight: bold;
          font-style: normal;
          font-display: swap;
      }
      body { font-family: 'DaxlinePro'; }
      h1, h2, h3 {
        font-family: 'DaxlinePro';
        font-weight: bold;
        font-size: 30px;
      }
      .title {
          font-size: 60px;
          font-weight: bold;
      }
      .remark-code, .remark-inline-code {
          font-family: Inconsolata,Fira code,Andale Mono,monospace;
          color: rgb(28, 68, 90);
          background-color: rgb(233,244,250)
      }
      .remark-slide-content { background-size: contain; }
      .remark-slide-content h1 { font-size: 2em; }
      .remark-slide-content h2 { font-size: 1.7em; }
      .remark-slide-content h3 { font-size: 1.3em; }
      .left-column {
          width: 49%%;
          float: left;
      }
      .right-column {
          width: 49%%;
          float: right;
      }
      blockquote {
          border-left-style: solid;
          border-left-width: 5px;
          border-left-color: #3D96D8;
          background-color: rgb(233,244,250);
          padding-left: 2em;
          padding-right: 2em;
          font-style: italic;
      }
      .no-number .remark-slide-number {
          display: none;
      }
    </style>
  </head>
  <body>
    <textarea id="source">
class:middle, no-number
background-image: url(bg_home.png)
background-position: top

<span><img style="position:absolute; right:5%%; bottom:5%%; width:24%%;" src="Tarides.svg"/></span>
<span class="title" style="position:absolute; top:33%%; color: white;">%s</span>
|html} title title

(* <!-- div.remark-slide-number.display: none *)
let trailer =
  {html|
    </textarea>
    <script src="https://remarkjs.com/downloads/remark-latest.min.js">
    </script>
    <script>
      var slideshow = remark.create();
    </script>
  </body>
</html>
|html}

let ( let< ) ic f =
  Fun.protect ~finally:(fun () -> In_channel.close ic) (fun () -> f ic)

let output_html file title =
  let< ic = In_channel.open_text file in
  let s = In_channel.input_all ic in
  print_string (header title);
  print_string s;
  print_string trailer

let _ = output_html Sys.argv.(1) Sys.argv.(2)
