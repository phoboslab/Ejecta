var width = window.innerWidth;
//----------------------------------------------------

(function (global) {
  var document = global.document;
  var createElement = document.createElement;
  document.createElement = function (name) {
    var elem = createElement(name);
    elem.style = new CSSStyleDeclaration();
    return elem;
  };
  document.createElementNS =  function (ns, name) {
    var elem = createElement(name);
    elem.style = new CSSStyleDeclaration();
    return elem;
  };
  document.querySelector = function (s) {
    if (s === "body") {
      return document.body;
    } else {
      console.log("document.querySelector selector", s);
      return document.createElement("foobar");
    }
  };
})(this);

(function (global) {
  global.Element = global.HTMLElement;
  global.Element.prototype.setAttributeNS = function (ns, name, value) {
    this.setAttribute(name, value);
  };
  Object.defineProperty(global.Element.prototype, "ownerDocument", {
    get: function () {
      console.log("ownerDocument called");
      return global.document;
    }
  });
})(this);

(function (global) {
  global.CSSStyleDeclaration = function () {};
  global.CSSStyleDeclaration.prototype.setProperty = function (name, value) {
    console.log("CSSStyleDeclaration.setProperty", name, value);
  };
})(this);

//----------------------------------------------------

var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;

//----------------------------------------------------

var d3 = require('vendor/d3.js');
console.log("d3", d3);

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-120)
    .linkDistance(30)
    .size([width, height]);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

d3.json("d3demo/miserables.json", function(error, graph) {
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var node = svg.selectAll(".node")
      .data(graph.nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", 5)
      .style("fill", function(d) { return color(d.group); })
      .call(force.drag);

  node.append("title")
      .text(function(d) { return d.name; });

  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  });

  // resulting SVG should be in document.body.svg
});
