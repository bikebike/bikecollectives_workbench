var Translator = function(urlTemplate) {
    this.urlTemplate = urlTemplate;
    this.translator = document.createElement('div');
    this.translator.id = 'translator';
    this.variableRegex = /%\{(.*?)\}/g;
    this.variableTemplate = '%{$1}';
    this.varBtnTemplate = '<input type="submit" value="$1" class="variable">';
    this.lastCaretPosition = 0;
    this._onclose = null;
    this._afterSave = null;
    this.orginalValue = null;
    this.replacementMode = {
        NONE: 0,
        INTERNAL: 1,
        DEMO: 2
    };

    document.body.appendChild(this.translator);
};

Translator.prototype.selectKey = function(key) {
    var request = new XMLHttpRequest(), _this = this;
    request.onreadystatechange = function() {
        if (request.readyState === 4) {
            if (request.status === 200) { 
                _this.translator.innerHTML = request.responseText;
                _this.translator.getElementsByTagName('form')[0].addEventListener('submit', function(event) {
                    event.preventDefault();
                    _this.save();
                });
                _this.translator.querySelector('header .close').addEventListener('click', function(event) {
                    event.preventDefault();
                    _this.close();
                });
                _this.translator.getElementsByClassName('exit-demo')[0].addEventListener('click', function(event) {
                    event.preventDefault();
                    _this.demo.className = 'demo';
                });
                _this.translator.getElementsByClassName('mobile-toggle')[0].addEventListener('click', function(event) {
                    event.preventDefault();
                    _this.demo.getElementsByTagName('iframe')[0].classList.toggle('mobile');
                });
                _this.input = _this.translator.getElementsByClassName('input')[0];
                _this.renderedInput = _this.translator.getElementsByClassName('rendered-input')[0];
                _this.translation = _this.translator.getElementsByClassName('translation')[0];
                _this.setValue(_this.input.innerHTML);
                _this.input.addEventListener('keydown', function(event) {
                    if (_this.handleKey(event.key, event.ctrlKey, event.shiftKey, event.altKey)) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                });
                _this.input.addEventListener('input', function() { _this.onchange(); });
                _this.input.addEventListener('blur', function() {
                    _this.lastCaretPosition = _this.getCaretPosition();
                });

                if (_this.input.getAttribute('data-vars')) {
                    var vars = _this.translator.getElementsByClassName('variables')[0].
                                getElementsByClassName('var');
                    for (var i = 0; i < vars.length; i++) {
                        vars[i].addEventListener('click', function(event) {
                            event.preventDefault();
                            _this.insertVar(event.target.getAttribute('data-var'));
                        });
                    }
                }
                _this.demo = _this.translator.getElementsByClassName('demo')[0];
                var screenshots = _this.translator.getElementsByClassName('screenshots')[0].
                                    getElementsByClassName('screenshot');
                for (var i = 0; i < screenshots.length; i++) {
                    screenshots[i].addEventListener('click', function(event) {
                        event.preventDefault();
                        _this.openDemo(event.target.getAttribute('href'));
                        _this.demo.getElementsByTagName('iframe')[0].onload = function() {
                            _this.initDemo();
                        };
                    });
                }
            } else {
            }
        }
    }
     
    request.open('GET', this.urlTemplate.replace(':key', key));
    request.send();
    this.translator.classList.add('open');
};

Translator.prototype.handleKey = function(key, ctrl, shift, alt) {
    switch (key) {
        case "Enter":
            if (!ctrl) {
                this.save();
                return true;
            }
            break;
    }
    return false;
};

Translator.prototype.save = function() {
    if (this.translation.value === this.orginalValue) {
        // don't save if nothing change
        return;
    }

    this.translator.classList.add('working');
    var form = this.translator.getElementsByTagName('form')[0];
    var request = new XMLHttpRequest();
    var _this = this;
    request.onreadystatechange = function() {
        if (request.readyState == 4) {
            if (request.status == 200) {
                var result = JSON.parse(request.responseText);
                _this.translator.classList.remove('working');
                _this.setValue(result.translation);
                if (_this._afterSave) {
                    _this._afterSave(result);
                }
            }
        }
    }
    request.open('POST', form.getAttribute('action'), true);
    request.send(new FormData(form));
};

Translator.prototype.initDemo = function() {
    var iframe = this.demo.getElementsByTagName('iframe')[0].contentDocument,
        title = this.demo.getElementsByClassName('title')[0]
        description = this.demo.getElementsByClassName('description')[0],
        metaDesc = iframe.querySelector('head meta[name="description"]');
    
    title.innerHTML = iframe.title;
    description.innerHTML = metaDesc.getAttribute('content');
};

Translator.prototype.openDemo = function(demoUrl) {
    this.demo.getElementsByTagName('iframe')[0].src = demoUrl;
    this.demo.className = 'demo open';
};

Translator.prototype.insertVar = function(varName) {
    var buttonContainer = document.createElement('div');
    buttonContainer.innerHTML = varName.replace(/^(.*)$/, this.varBtnTemplate);
    this.insert(buttonContainer.childNodes[0]);
};

Translator.prototype.insert = function(text) {
    if (this.input !== document.activeElement) {
        this.input.focus();
        this.setCaretPosition(this.lastCaretPosition);
    }
    var sel = window.getSelection();
    if (sel.getRangeAt && sel.rangeCount) {
        var range = sel.getRangeAt(0);
        range.deleteContents();

        var content = text, length = 0;
        if (typeof text === "string") {
            content = document.createTextNode(text);
            length = text.length;
        }
        range.insertNode(content);

        var range2 = document.createRange();
        var sel2 = window.getSelection();
        range2.setStartAfter(content);
        range2.setEndAfter(content); 
        sel2.removeAllRanges();
        sel2.addRange(range2);
        this.updateRenderedInput();
    }
};

Translator.prototype.setCaretPosition = function(pos, element) {
    var el = element || this.input;
    // Loop through all child nodes
    for (var node of el.childNodes) {
        if (node.nodeType === Node.TEXT_NODE) { // we have a text node
            if (node.length >= pos) {
                // finally add our range
                var range = document.createRange(), sel = window.getSelection();
                range.setStart(node,pos);
                range.collapse(true);
                sel.removeAllRanges();
                sel.addRange(range);
                return -1; // we are done
            } else {
                pos -= node.length;
            }
        } else {
            // return pos - 1;
            pos = this.setCaretPosition(pos, node);
            if (pos === -1) {
                return -1; // no need to finish the for loop
            }
        }
    }
    return pos; // needed because of recursion stuff
};

Translator.prototype.getCaretPosition = function() {
    var caretOffset = 0, element = this.input;
    var doc = element.ownerDocument || element.document;
    var win = doc.defaultView || doc.parentWindow;
    var sel;
    if (typeof win.getSelection !== "undefined") {
        sel = win.getSelection();
        if (sel.rangeCount > 0) {
            var range = win.getSelection().getRangeAt(0);
            var preCaretRange = range.cloneRange();
            preCaretRange.selectNodeContents(element);
            preCaretRange.setEnd(range.endContainer, range.endOffset);
            caretOffset = preCaretRange.toString().length;
        }
    } else if ((sel = doc.selection) && sel.type != "Control") {
        var textRange = sel.createRange();
        var preCaretTextRange = doc.body.createTextRange();
        preCaretTextRange.moveToElementText(element);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        caretOffset = preCaretTextRange.text.length;
    }
    return caretOffset;
}

Translator.prototype.onchange = function() {
    this.updateRenderedInput();
    var value = this.input.innerHTML,
        cleanedText = this.replaceVars(this.cleanText(value, this.getVars()));
    if (cleanedText !== value) {
        var caret = caret = this.getCaretPosition();
        this.input.innerHTML = cleanedText;
        this.setCaretPosition(caret);
    }
};

Translator.prototype.onclose = function(fn) {
    this._onclose = fn;
};

Translator.prototype.afterSave = function(fn) {
    this._afterSave = fn;
};

Translator.prototype.close = function() {
    this.translator.removeAttribute('class');
    if (this._onclose) {
        this._onclose(); 
    }
};

Translator.prototype.getVars = function() {
    this.vars = this.vars || JSON.parse(this.input.getAttribute('data-vars'));
    return this.vars;
};

Translator.prototype.setValue = function(value) {
    this.orginalValue = value;
    this.input.innerHTML = this.replaceVars(this.cleanText(value, this.getVars()));
    this.updateRenderedInput();
};

Translator.prototype.updateRenderedInput = function() {
    if (this.renderedInput) {
        this.renderedInput.innerHTML =
            this.renderExample(this.input.innerHTML, this.getVars());
    }
    var newValue = this.cleanText(this.input.innerHTML, this.getVars(), this.replacementMode.INTERNAL);
    this.translation.value = newValue;

    this.translator.getElementsByTagName('form')[0].getElementsByTagName('button')[0].disabled =
        this.orginalValue === newValue;
};

Translator.prototype.renderExample = function(value, vars) {
    return this.cleanText(value, vars, this.replacementMode.DEMO);
};

Translator.prototype.cleanText = function(value, vars, replacementMode) {
    // console.log(replacementMode);
    // console.log(value);
    var temp = document.createElement('div');
    temp.innerHTML = value;
    var children = temp.childNodes;
    var index = 0;

    while (children && children[index]) {
        var child = children[index];
        if (child.tagName === 'INPUT' && child.className === 'variable' &&
                child.type === 'submit' && vars[child.value]) {
            // if this is one of our variable buttons, determine if we want to replace it
            if (replacementMode === this.replacementMode.DEMO) {
                child.outerHTML = vars[child.value];
            } else if (replacementMode === this.replacementMode.INTERNAL) {
                child.outerHTML = child.value.replace(/^(.*)$/, this.variableTemplate);
            } else {
                // for our translator, we just want to leave these elements be
                index++;
            }
        } else if (child.tagName) {
            // if this is an HTML element strip out the HTML
            child.outerHTML = child.textContent || child.innerText;
        } else {
            // otherwise this is a comment or a text node, skip it
            index++;
        }

    }
    // var variables = temp.getElementsByTagName('input');
    // while (variables && variables.length) {
    //     variables[0].outerHTML = vars[variables[0].value];
    // }

    // console.log(value);
    return temp.innerHTML;
};

Translator.prototype.replaceInputVars = function() {
    var oldValue = input.innerHTML, newValue = _this.replaceVars(oldValue);
    if (newValue != oldValue) {
        input.innerHTML = newValue;
    }
}

Translator.prototype.replaceVars = function(string) {
    return string.replace(this.variableRegex, this.varBtnTemplate);
};

Translator.prototype.varHtml = function(name) {
    return '<input type="submit value="' + name + '">';
};

document.addEventListener('DOMContentLoaded', function() {
    var table = document.getElementById('translation-list');
    var translator = null;

    function enterFullscreen() {
        document.body.classList.add('fullscreen');
    }

    function exitFullscreen() {
        document.body.classList.remove('fullscreen');
    }

    document.addEventListener('click', function(event) {
        if (table.contains(event.target)) {
            var key = null, element = event.target;
            while (key === null && element !== table) {
                if (element.getAttribute('data-key')) {
                    key = element.getAttribute('data-key');
                }
                element = element.parentElement;
            }

            if (key) {
                if (!translator) {
                    translator = new Translator(table.getAttribute('data-translator-path'));
                    translator.onclose(function() { exitFullscreen(); });
                    translator.afterSave(function(data) {
                        var key = table.querySelector('tr[data-key="' + data.key + '"] .value');
                        key.innerHTML = data.formattedValue;
                    });
                }
                translator.selectKey(key);
                enterFullscreen();
            }
        }
    });
})
;
