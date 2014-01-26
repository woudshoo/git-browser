function removeToInsertLater(element) {
  var parentNode = element.parentNode;
  var nextSibling = element.nextSibling;
  parentNode.removeChild(element);
  return function() {
    if (nextSibling) {
      parentNode.insertBefore(element, nextSibling);
    } else {
      parentNode.appendChild(element);
    }
  };
}


filter_list = function (dom, value)
{
    var regexp = new RegExp (value, 'i');
    var root = dom.getElementsByTagName ("ul") [0];
    var children = root.children;

    var insertf = removeToInsertLater (root);
    
    for (var i = children.length - 1; i >= 0; -- i)
    {
	var item = children [i];
	if (regexp.test (item.innerText))
	{
	    item.style.display = 'block';
	}
	else
	{
	    item.style.display = 'none';
	}
    }
    insertf ();
}
