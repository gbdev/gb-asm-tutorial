// This is done as JS so as to occur *after* `highlight.js` inserts its `<span>`s

let linenoRegex = /^start=([0-9]+)$/;

for (let element of document.querySelectorAll('pre > code.linenos')) {
	let text = element.innerHTML;
	element.textContent = ''; // Remove all the code

	let lines = text.split('\n');
	// The last line is ignored if empty, but that won't be the case if we add a <span>, so remove it
	let last = lines.pop();
	if (last !== undefined && last !== '') {
		lines.push(last);
	}


	lines.forEach((line) => {
		let node = document.createElement('span');
		node.className = 'line';
		node.innerHTML = line + '\n';
		element.appendChild(node);
	});


	for (let className of element.classList) {
		let match = linenoRegex.exec(className);
		if (match) {
			element.style.setProperty('counter-reset', 'lineno ' + (parseInt(match[1]) - 1));
		}
	}
}
