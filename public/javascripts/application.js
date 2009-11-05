/* Change layout, style, and UI for savvy browsers. */
var deezy_layout = function() {
  return {
    notes:null,
    init:function() {
      float_and_center_page();
      deezy_layout.notes = $$('.notes_col');
      add_colorize_odd_rows();

      /* If there's an 'entries' table, set up expandable note previews. */
      if ($('entries')) set_up_note_previews();

      deezy_form_layout.init(); // Do the form layout
    },

    rgb2hex:function(rgb) {
      var m = /rgb\(([0-9]{1,3}),\s*([0-9]{1,3}),\s*([0-9]{1,3})/.exec(rgb);
      var hex = '#' + (m[1]*1).toString(16) + (m[2]*1).toString(16) + (m[3]*1).toString(16);
      return hex;
    } 
  };

  /* private methods */

  /* Float the page so it uses automatic width and center it */
  function float_and_center_page() {
    var inner = new Element('div').update($('header'));
    inner.appendChild($('content'));
    inner.appendChild($('footer'));
    inner.setStyle({position:'relative',left:'-50%'});
    var outer = new Element('div',{id:'pagewrapper'}).update(inner).setStyle({'float':'left',position:'relative',left:'50%'});
    $$('body')[0].update(outer).setStyle({overflowX:'hidden'});
    Event.observe(window,'resize',set_page_max_width);
    set_page_max_width();
  }

  /* Set maximum width of the page so it doesn't overflow the viewport */
  function set_page_max_width() {
    $('pagewrapper').firstDescendant().setStyle({maxWidth:document.viewport.getWidth()+'px'});
  }

  /* Set up note previews that can expand to show the whole note content. */
  function set_up_note_previews() {
    var notes = deezy_layout.notes;
    notes.expand = function() {
      notes.each(function(note) { if (note.expand) note.expand(); });
    };
    notes.collapse = function() {
      notes.each(function(note) { if (note.collapse) note.collapse(); });
    };

    notes.each(function(note) {
      var inner = note.innerHTML;
      var len = 24;
      if (inner.length > len) {
        var first = new Element('span').update(inner.substring(0,len));
        var last = new Element('span').update(inner.substring(len));
        var link = new Element('a',{href:'#'}).update('&raquo;');
        link.setStyle({fontSize:'14px',paddingLeft:'5px'});
        link.observe('click',function(evt) {
          evt.stop(); // Don't follow link
          note.toggle();
        });
        note.update(first);
        note.appendChild(last);
        note.appendChild(link);
        note.toggle = function() {
          last.toggle();
          note.toggleClassName('note_expanded');
          note.toggleClassName('note_collapsed');
          link.update(last.visible() ? '&laquo;' : '&raquo;');
        }
        note.expand = function() {
          last.show();
          note.addClassName('note_expanded');
          note.removeClassName('note_collapsed');
          link.update('&laquo;');
        }
        note.collapse = function() {
          last.hide();
          note.removeClassName('note_expanded');
          note.addClassName('note_collapsed');
          link.update('&raquo;');
        }
        note.collapse();
      }
    });
    add_collapse_expand_all_notes_links();
  }

  function add_collapse_expand_all_notes_links() {
      var th = $('notes_th');
      var links = new Element('span');
      links.setStyle({fontSize:'16px',padding:'0 5px'});
      var expand_link = new Element('a',{href:'#',title:'Expand all notes'}).update('&raquo;');
      var collapse_link = new Element('a',{href:'#',title:'Collapse all notes'}).update('&laquo;');
      expand_link.observe('click',function(evt) {
        evt.stop(); // Don't follow link
        deezy_layout.notes.expand();
      });
      collapse_link.observe('click',function(evt) {
        evt.stop(); // Don't follow link
        deezy_layout.notes.collapse();
      });
      links.appendChild(expand_link);
      links.appendChild(new Element('span').update('|').setStyle({fontSize:'14px',padding:'0 3px'}));
      links.appendChild(collapse_link);
      th.appendChild(links);

  }

  /* When you click the th for a column on a sortable table, re-colorize the
   * rows. */
  function add_colorize_odd_rows() {
    colorize_odd_rows();
    var ths = $$('.sortable th'); 
    ths.each(function(th) {
      th.observe('click',colorize_odd_rows);
    });
  }

  /* Colorize the odd rows */
  function colorize_odd_rows() {
    $$('.alt_rows tbody tr:nth-child(odd)').each(function(tr) { tr.addClassName('odd'); });
    $$('.alt_rows tbody tr:nth-child(even)').each(function(tr) { tr.removeClassName('odd'); });
  }
}();

/* Update the form layout and set up the UI */
var deezy_form_layout = function() {

  var form,scope,mac,ip,itgid,hostname,uid,enabled,notes,submit,dynamic_toggle_button;

  return {
    init:function() {

      $$('form').each(function(f) { if (/(_entry|entry_)/.match(f.id)) form = f; });

      if (!form) return;

      form.setStyle({'float':'left'});

      scope    = $('entry_scope');
      mac      = $('entry_mac');
      ip       = $('entry_ip');
      itgid    = $('entry_itgid');
      hostname = $('entry_hostname');
      uid      = $('entry_uid');
      enabled  = $('entry_enabled');
      notes    = $('entry_notes');
      submit   = $('entry_submit');

      /* Set all the fields to valid by default. */
      [scope,mac,ip,itgid,hostname,uid,enabled,notes].each(function(field) {
        field.valid = true;
      });

      /* Disable submit if necessary whenever we change fields. */
      [scope,mac,ip,itgid,hostname,uid,enabled,notes].each(function(field) {
        field.observe('blur',function() {
          field.value = field.value.strip();
          submit_toggler();
        });
      });

      form.valid = function() {
        var ret = true;
        [mac,ip,itgid,hostname,uid].each(function(field) {
          if (!field.validate()) ret = false;
        });
        return ret;
      }

      form.observe('submit',function(evt) { if (!form.valid()) evt.stop(); });

      /* Add validation to all the fields that need it. */
      [
        [mac,is_mac,'Must be a valid MAC address, i.e. 00:11:23:8f:ef:ab'],
        [ip,is_ip,'Must be a valid ITG IP address, i.e. 128.111.207.200 (<em>Leave <strong>blank</strong> if dynamic.</em>)'],
        [itgid,is_itgid,'Must be a valid ITG ID, i.e. 064001445'],
        [hostname,is_hostname,'Must be a valid hostname, i.e. itg061445'],
        [uid,is_hostname,'Must be a valid uid.']
        ].each(function(set) {
        add_validation(set[0],set[1],set[2]);
      });

      /* Force these fields to lowercase, then re-validate. */
      [mac,hostname,uid].each(function(field) {
        field.observe('blur',function() {
          field.value = field.value.toLowerCase();
          field.validate();
        });
      });

      /* Do various things. See related methods for details */
      [itgid,hostname].each(function(field) { field.observe('blur',suggest_hostname); });
      [scope,ip].each(function(field) { field.observe('change',match_ip_to_scope); });
      normalize_mac();
      show_ip_picker(form);
      add_dynamic_ip_checkbox();
      form.observe('keyup',submit_toggler);
      ip.observe('change',ip_unavailable_warning);
      //      add_other_to_scope(); //This will probably never be used.
      set_up_toggle_buttons();
      add_dynamic_ip_click_listener();
    }
  };

  /* private methods */

  function add_dynamic_ip_click_listener() {
    var button = $('dynamic_toggle').firstDescendant();
    button.observe('click',toggle_ip);
    dynamic_toggle_button = $$('#dynamic_toggle button')[0];
  }

  function set_up_toggle_buttons() { 
    var buttons = $$('.toggle_button');
    buttons.each(function(tbutton) {
      tbutton.removeClassName('toggle_button');
      var cbox = null;
      var hbox = null;
      $A(tbutton.getElementsByTagName('input')).each(function(cb) {
        if (cb.type == 'hidden') hbox = cb;
        if (cb.type == 'checkbox') cbox = cb;
      });
      var label = tbutton.getElementsByTagName('label')[0];
      var button = new Element('button');
      var p = new Element('p');
      p.setStyle({whiteSpace:'pre'});
      button.update(p);
      var on = new Element('img', { src : '/images/on.png' });
      var off = new Element('img', { src : '/images/off.png' });
      p.appendChild(on);
      p.appendChild(off);
      p.appendChild(label);
      if (hbox) p.appendChild(hbox);
      p.appendChild(cbox);
      tbutton.update(button);
      on.hide();
      off.hide();
      cbox.hide();
      var state = cbox.checked ? on : off;
      state.toggle();
      button.on = function() {
        on.show();
        off.hide();
        cbox.checked = true;
      }
      button.off = function() {
        off.show();
        on.hide();
        cbox.checked = false;
      }
      button.toggle = function() {
        off.toggle();
        on.toggle();
        cbox.checked = !cbox.checked;
      }

      button.observe('click',function(evt) {
        evt.stop();
        button.toggle();
      });
    });
  }

  /* Warn if the IP set doesn't appear in the list of available IPs, but don't
   * prevent it. */
  function ip_unavailable_warning() {
    var lis = $$('#ip_picker li');
    var ips = new Array();
    lis.each(function(li) {
      ips.push(li.innerHTML);
    });
    if (is_ip(ip) && ips.indexOf(ip.value) == -1 && !ip.value.blank()) {
      alert("WARNING:\n\nThis IP address doesn't seem to be available or is not in the usual range.\n\nOnly use it if you REALLY know what you're doing.");
    }
  }

  /* Add checkbox for Dynamic IP address. If this is a new entry, use dynamic
   * by default. */
  function add_dynamic_ip_checkbox() {
    var span = new Element('span',{id:'dynamic_toggle'}).addClassName('toggle_button');
    var checkbox = new Element('input',{type:'checkbox',id:'dyn_check',name:'dynamic_ip'});
    var label = new Element('label',{'for':'dyn_check'}).update('Dynamic');
    var p = ip.parentNode;
    p.setStyle({'float':'left',marginRight:'5px'});
    span.update(label);
    span.appendChild(checkbox);
    Element.insert(p,{after:span});
    Element.insert(span,{after:new Element('br',{style:'clear:both'})});
    if (ip.value.blank()) {
      $('dyn_check').checked = 'checked';
      toggle_ip();
    }
  }

  /* Disable the IP field and make sure the Dynamic IP checkbox is checked. */
  function toggle_ip(evt) {
    if (evt) evt.stop();
    if (ip.disabled) enable_ip();
    else disable_ip();
  }

  function disable_ip() {
    ip.disabled = true;
    ip.addClassName('field_disabled');
    var invisible_ip = new Element('input',{type:'hidden',value:'',name:ip.name,id:'invis_ip'});
    if (!is_ip(ip)) { ip.value = ''; ip.validate(); }
    Element.insert(ip,{after:invisible_ip});
  }

  function enable_ip() {
    var invis_ip = $('invis_ip');
    if (invis_ip) Element.remove(invis_ip);
    ip.removeClassName('field_disabled');
    ip.disabled = false;
  }

  /* Create and insert the IP picker */
  function show_ip_picker(form) {
    var picker = $('ip_picker');
    if (!picker) {
      picker = new Element('div',{ id:'ip_picker' });
      picker.setStyle({
        minWidth:'110px',
        background:'#e0efe0',
        border:'1px solid #999',
        height:form.getHeight()-10+'px',
        padding:'5px',
        'float':'left',
        overflowY:'scroll',
        marginLeft:'10px'
      });
      picker.update(new Element('ul'));
      $('content').appendChild(picker);
      picker.hide();
      update_ip_picker(form,picker);
    }
    scope.observe('change',function() { update_ip_picker(form,picker); });
  }

  /* Update the IP picker with a fresh list of available IPs when the scope is
   * changed */
  function update_ip_picker(form,picker) {
    var ul = $$('#ip_picker ul')[0];
    ul.update('Loading...'); //clear the current contents
    picker.show();
    var free_ips;
    new Ajax.Request('/freeips.json', {
      method:'get',
      onSuccess:function(transport) {
        ul.update();
        var free_ips = transport.responseText.evalJSON().free_ips;
        var list;
        free_ips.scopes.each(function(s) {
          if (s.id == scope.value) list = s; //find the appropriate list by scope
        });
        list.ips.each(function(i) {
          var li = new Element('li').update(i.ip);
          li.setStyle({cursor:'pointer'});
          li.observe('click',function() {
            if (dynamic_toggle_button) dynamic_toggle_button.off();
            enable_ip();
            ip.value = i.ip; //set the IP field to match the clicked IP
            ip.validate();
            var endcolor = deezy_layout.rgb2hex(picker.getStyle('background-color'));
            new Effect.Highlight(li,{endcolor:endcolor});
            new Effect.Highlight(ip);
          });
          ul.appendChild(li);
        });
      }
    });
  }

  /* Normalize the MAC address in case it was entered with incorrect
   * punctuation or something. */
  function normalize_mac() {
    mac.observe('blur',function() {
      mac.value = mac.value.replace(/[^0-9a-f]/g,'');
      mac.value = mac.value.replace(/(..)(..)(..)(..)(..)(..)/,'$1:$2:$3:$4:$5:$6');
      mac.validate();
    });
  }

  /* Update the ip field so that it matches whichever scope is selected */
  function match_ip_to_scope() {
    var real_scope;
    $$('select').each(function(i) { if (i.name == scope.name) real_scope = i; });
    $$('input').each(function(i) { if (i.name == scope.name) real_scope = i; });
    ip.value = ip.value.replace(/^128\.111\.(20[67]|186)\.([0-9]{0,3})$/,'128.111.'+real_scope.value+'.$2');
  }

  /* Suggest a hostname based on the itgid */
  function suggest_hostname() {
    if (hostname.value.blank() && itgid.valid) {
      var v = itgid.value;
      hostname.value = 'itg'+v.substring(0,2)+v.substring(5)
      hostname.validate();
    }
  }

  /* Toggle the submit.disabled if necessary */
  function submit_toggler() {
    var disabled = !(mac.valid && ip.valid && itgid.valid && hostname.valid && uid.valid);
    submit.disabled = disabled;
  }

  /* Attach validation events to a node. Takes the node, its validation
   * function, and the error message to display when the field is invalid. */
  function add_validation(node,func,msg) {
    /* Add a function so we can just call node.validate() whenever we want. */
    node.validate = function() {
      return validate_field(node,func,msg);
    };
    /* Attach event listeners, but make sure we only do it once by using
     * has_blur and has_keyup to keep track. */
    if (!node.has_blur) {
      node.observe('blur',function() {
        node.validate();
        node.has_blur = true;
        if (!node.has_keyup) {
          node.observe('keyup',function() {
            node.validate();
            node.has_keyup = true;
          });
        }
      });
    }
  }

  /* Generic field validation. Takes the node, its validation function, and the
   * error message to display when the field is invalid. */
  function validate_field(node,func,msg) {
    if (!func(node)) {
      node.addClassName('invalid_field');
      node.valid = false;
      var span = $(node.id+'_invalid');
      if (!span) {
        span = new Element('span',{id:node.id+'_invalid'}).update('&larr; '+msg).addClassName('invalid_tip');
        Element.insert(node,{after:span});
      }
    }
    else {
      node.valid = true;
      node.removeClassName('invalid_field');
      if ($(node.id+'_invalid')) {
        Element.remove($(node.id+'_invalid'));
      }
    }
    return node.valid;
  }

  /* Validation methods
   *
   * The following methods accept a value (string) or DOM node with value
   * attribute and return true if the datum is valid. */

  /* Is it a valid ITG ID? Like 988000132 or 064001223 */
  function is_itgid(i) {
    var i = typeof(i) == 'object' ? i.value : i;
    return /^[0-9]{2}[48]00[0-9]{4}$/.match(i);
  }

  /* Valid ITG IP address? In 128.111.206.0/23 or 128.111.186.0/24. MAY BE BLANK! */
  function is_ip(i) {
    var i = typeof(i) == 'object' ? i.value : i;
    return /^128.111.(20[67]|186).([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/.match(i) || i.blank();
  }

  /* Valid MAC address? i.e. 00:12:34:ab:cd:9f */
  function is_mac(m) {
    var m = typeof(m) == 'object' ? m.value : m;
    return /^[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}$/.match(m); 
  }

  /* Valid hostname? Between 1-63 characters, only lowercase letters, numbers,
   * and hyphens. Must not begin or end with hyphen. sci-lab83 ok. Sci-lab83
   * not ok. harold-maude ok. haroldmaude- not ok.
   * (This validation also works for usernames (aka uid).)*/
  function is_hostname(h) {
    var h = typeof(h) == 'object' ? h.value : h;
    return /^[0-9a-z]([0-9a-z-]{0,61}[0-9a-z]|[0-9a-z])$/.match(h);
  }

}();

Event.observe(window,'load',function() {
  deezy_layout.init();
});
