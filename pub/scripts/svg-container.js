






setSVGContentSize = function (node)
{
    var svgContainer = document.getElementById (node)
    var svg = svgContainer.getElementsByTagName ('svg') [0]
    var csvg = svg.parentElement

    csvg.style.width = svg.getAttribute ('width')
    csvg.style.height = svg.getAttribute ('height')
}




mad = function (node, id) {
    var element = document.getElementById (id)
    var child = element.getElementsByTagName ('polygon') [0]
    
    child.setAttribute ('fill', 'gray')
    initiateActionWithArgs ('mark-as-dead', '', {id: id})
}


zoomout = function (node) {


    var parent = node.parentNode
    var svg = parent.getElementsByTagName ('svg') [0]

//    listProperties (vb.toArray ())


    var w = svg.width.baseVal.value
    var h = svg.height.baseVal.value

    var w2 = w  / 2
    var h2 = h / 2
    svg.setAttribute ('width', '' + w2 + 'px');
    svg.setAttribute ('height', '' +  h2 + 'px');
    svg.parentElement.setAttribute ('height', '100%');
    svg.parentElement.setAttribute ('width', '100%');
//    svg.setAttribute ('viewBox', '0.0 0.0 ' + w + '.0 ' + h2 + '.0')
/*
//    alert ('w: ' + w + '  H: ' + h);

//    alert ('w2: ' + svg.getAttribute ('width') + '  h2: ' + svg.getAttribute ('height'))
//    alert ('w2: ' + 0.5 * w + '  h2: ' + 0.5 * h)
//    alert (svg.zoomAndPan)
//    svg.zoomAndPan = 1
//    svg.currentScale *= 2
//    alert(svg.viewBox)
//    alert ('width: ' + svg.viewBox.baseVal.width + ' height: ' + svg.viewBox.baseVal.height + ' x: ' + svg.viewBox.baseVal.x + ' y: ' + svg.viewBox.baseVal.y)
//    alert (svg.viewport)
//    alert ('width: ' + svg.viewport.width + ' height: ' + svg.viewport.height + ' x: ' + svg.viewport.x + ' y: ' + svg.viewport.y)
//    alert ('width: ' + svg.width.baseVal.value + '  height: ' + svg.height.baseVal.value)
//    svg.width.baseVal.value = 1000
//    svg.height.baseVal.value = 1000
//    svg.viewBox.baseVal.width = 1000
//    svg.viewBox.baseVal.height = 1000
//    svg.viewBox.baseVal.width = 100
//    svg.viewBox.baseVal.height = 100
//    setCTM (svg, svg.getCTM ().scale (2))
//    alert (svg.getCTM ().a)

//    listProperties (svg.getCTM ())
*/
}


function listProperties(obj) {
    var propList = "";
    for(var propName in obj) {
       if(typeof(obj[propName]) != "undefined") {
          propList += (propName + ", ");
       }
    }
    alert(propList);
}


