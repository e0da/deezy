/* JSLint note: The following variables are pre-defined by Prototype, DOM, or JavaScript itself */
/* $,$$,$A,Element,Event,alert,Ajax,Effect,window,document */

/* Update the form layout and set up the UI */
var deezy_form_layout = function() {

  /* member variables */
  var form,scope,mac,ip,itgid,room,hostname,uid,enabled,notes,submit,dynamic_toggle_button;

  /* private methods */ 
  var add_dynamic_ip_click_listener,set_up_toggle_buttons,ip_unavailable_warning,add_dynamic_ip_checkbox,toggle_ip,disable_ip,enable_ip,show_ip_picker,update_ip_picker,normalize_mac,normalize_room,match_ip_to_scope,suggest_hostname,submit_toggler,add_validation,validate_field,is_itgid,is_room,is_ip,is_mac,is_hostname,rgb2hex;

  add_dynamic_ip_click_listener = function() {
    var button = $('dynamic_toggle').firstDescendant();
    button.observe('click',toggle_ip);
    dynamic_toggle_button = $$('#dynamic_toggle button')[0];
  };

  set_up_toggle_buttons = function() { 
    var buttons = $$('.toggle_button');
    buttons.each(function(tbutton) {
      tbutton.removeClassName('toggle_button');
      var cbox = null;
      var hbox = null;
      $A(tbutton.getElementsByTagName('input')).each(function(cb) {
        if (cb.type == 'hidden') { hbox = cb; }
        if (cb.type == 'checkbox') { cbox = cb; }
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
      if (hbox) { p.appendChild(hbox); }
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
      };
      button.off = function() {
        off.show();
        on.hide();
        cbox.checked = false;
      };
      button.toggle = function() {
        off.toggle();
        on.toggle();
        cbox.checked = !cbox.checked;
      };

      button.observe('click',function(evt) {
        evt.stop();
        button.toggle();
      });
    });
  };

  /* Warn if the IP set doesn't appear in the list of available IPs, but don't
   * prevent it. */
  ip_unavailable_warning = function() {
    var lis = $$('#ip_picker li');
    var ips = [];
    lis.each(function(li) {
      ips.push(li.innerHTML);
    });
    if (is_ip(ip) && ips.indexOf(ip.value) == -1 && !ip.value.blank()) {
      alert("WARNING:\n\nThis IP address doesn't seem to be available or is not in the usual range.\n\nOnly use it if you REALLY know what you're doing.");
    }
  };

  /* Add checkbox for Dynamic IP address. If this is a new entry, use dynamic
   * by default. */
  add_dynamic_ip_checkbox = function() {
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
  };

  /* Disable the IP field and make sure the Dynamic IP checkbox is checked. */
  toggle_ip = function(evt) {
    if (evt) { evt.stop(); }
    if (ip.disabled) { enable_ip(); }
    else { disable_ip(); }
  };

  disable_ip = function() {
    ip.disabled = true;
    ip.addClassName('field_disabled');
    var invisible_ip = new Element('input',{type:'hidden',value:'',name:ip.name,id:'invis_ip'});
    if (!is_ip(ip)) { ip.value = ''; ip.validate(); }
    Element.insert(ip,{after:invisible_ip});
  };

  enable_ip = function() {
    var invis_ip = $('invis_ip');
    if (invis_ip) { Element.remove(invis_ip); }
    ip.removeClassName('field_disabled');
    ip.disabled = false;
  };

  /* Create and insert the IP picker */
  show_ip_picker = function(form) {
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
  };

  /* Update the IP picker with a fresh list of available IPs when the scope is
   * changed */
  update_ip_picker = function(form,picker) {
    var ul = $$('#ip_picker ul')[0];
    ul.update('Loading...'); //clear the current contents
    picker.show();
    var free_ips;
    var req = new Ajax.Request('/freeips.json', {
      method:'get',
      onSuccess:function(transport) {
        ul.update();
        free_ips = transport.responseText.evalJSON().free_ips;
        var list;
        free_ips.scopes.each(function(s) {
          if (s.id == scope.value) { list = s; } //find the appropriate list by scope
        });
        list.ips.each(function(i) {
          var li = new Element('li').update(i.ip);
          li.setStyle({cursor:'pointer'});
          li.observe('click',function() {
            if (dynamic_toggle_button) { dynamic_toggle_button.off(); }
            enable_ip();
            ip.value = i.ip; //set the IP field to match the clicked IP
            ip.validate();
            var endcolor = rgb2hex(picker.getStyle('background-color'));
            var hili = new Effect.Highlight(li,{endcolor:endcolor});
            var hiip = new Effect.Highlight(ip);
            hili = hiip = null;
          });
          ul.appendChild(li);
        });
      }
    });
    free_ips = req = null;
  };

  /* Normalize the MAC address in case it was entered with incorrect
   * punctuation or something. */
  normalize_mac = function() {
    mac.observe('blur',function() {
      mac.value = mac.value.replace(/[^0-9a-f]/g,'');
      mac.value = mac.value.replace(/(..)(..)(..)(..)(..)(..)/,'$1:$2:$3:$4:$5:$6');
      mac.validate();
    });
  };

  /* Normalize the room number */
  normalize_room = function() {
    room.observe('blur',function() {
      room.value = room.value.match(/[0-9]{4}[a-zA-Z]?/)[0].toUpperCase();
      room.validate();
    });
  };

  /* Update the ip field so that it matches whichever scope is selected */
  match_ip_to_scope = function() {
    var real_scope;
    $$('select').each(function(i) { if (i.name == scope.name) { real_scope = i; } });
    $$('input').each(function(i) { if (i.name == scope.name) { real_scope = i; } });
    ip.value = ip.value.replace(/^128\.111\.(20[67]|186)\.([0-9]{0,3})$/,'128.111.'+real_scope.value+'.$2');
  };

  /* Suggest a hostname based on the itgid */
  suggest_hostname = function() {
    if (hostname.value.blank() && itgid.valid) {
      var v = itgid.value;
      hostname.value = 'itg'+v.substring(0,2)+v.substring(5);
      hostname.validate();
    }
  };

  /* Toggle the submit.disabled if necessary */
  submit_toggler = function() {
    var disabled = !(mac.valid && ip.valid && itgid.valid && room.valid && hostname.valid && uid.valid);
    submit.disabled = disabled;
  };

  /* Attach validation events to a node. Takes the node, its validation
   * function, and the error message to display when the field is invalid. */
  add_validation = function(node,func,msg) {
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
  };

  /* Generic field validation. Takes the node, its validation function, and the
   * error message to display when the field is invalid. */
  validate_field = function(node,func,msg) {
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
  };

  /* Validation methods
   *
   * The following methods accept a value (string) or DOM node with value
   * attribute and return true if the datum is valid. */

  /* Is it a valid ITG ID? Like 988000132 or 064001223 */
  is_itgid = function(i) {
    var j = typeof(i) == 'object' ? i.value : i;
    return (/^[0-9]{2}[48]00[0-9]{4}$/).match(j);
  };

  /* Is it a valid room? Like 4203G or 1142 */
  is_room = function(i) {
    var j = typeof(i) == 'object' ? i.value : i;
    return (/^[0-9]{4}[A-Z]?$/).match(j);
  };

  /* Valid ITG IP address? In 128.111.206.0/23 or 128.111.186.0/24. MAY BE BLANK! */
  is_ip = function(i) {
    var j = typeof(i) == 'object' ? i.value : i;
    return (/^128.111.(20[67]|186).([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/).match(j) || j.blank();
  };

  /* Valid MAC address? i.e. 00:12:34:ab:cd:9f */
  is_mac = function(m) {
    var n = typeof(m) == 'object' ? m.value : m;
    return (/^[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}$/).match(n); 
  };

  /* Valid hostname? Between 1-63 characters, only lowercase letters, numbers,
   * and hyphens. Must not begin or end with hyphen. sci-lab83 ok. Sci-lab83
   * not ok. harold-maude ok. haroldmaude- not ok.
   * (This validation also works for usernames (aka uid).)*/
  is_hostname = function(h) {
    var i = typeof(h) == 'object' ? h.value : h;
    return (/^[0-9a-z]([0-9a-z\-]{0,61}[0-9a-z]|[0-9a-z])$/).match(i);
  };

  rgb2hex = function(rgb) {
    var m = /rgb\(([0-9]{1,3}),\s*([0-9]{1,3}),\s*([0-9]{1,3})/.exec(rgb);
    var hex = '#' + (m[1]*1).toString(16) + (m[2]*1).toString(16) + (m[3]*1).toString(16);
    return hex;
  };

  return {
    init:function() {

      $$('form').each(function(f) { if (/(_entry|entry_)/.match(f.id)) { form = f; } });

      if (!form) { return; }

      form.setStyle({'float':'left'});

      scope    = $('entry_scope');
      mac      = $('entry_mac');
      ip       = $('entry_ip');
      itgid    = $('entry_itgid');
      room     = $('entry_room');
      hostname = $('entry_hostname');
      uid      = $('entry_uid');
      enabled  = $('entry_enabled');
      notes    = $('entry_notes');
      submit   = $('entry_submit');

      /* Set all the fields to valid by default. */
      [scope,mac,ip,itgid,room,hostname,uid,enabled,notes].each(function(field) {
        field.valid = true;
      });

      /* Disable submit if necessary whenever we change fields. */
      [scope,mac,ip,itgid,room,hostname,uid,enabled,notes].each(function(field) {
        field.observe('blur',function() {
          field.value = field.value.strip();
          submit_toggler();
        });
      });

      form.valid = function() {
        var ret = true;
        [mac,ip,itgid,room,hostname,uid].each(function(field) {
          if (!field.validate()) { ret = false; }
        });
        return ret;
      };

      form.observe('submit',function(evt) { if (!form.valid()) { evt.stop(); } });

      /* Add validation to all the fields that need it. */
      [
        [mac,is_mac,'Must be a valid MAC address, i.e. 00:11:23:8f:ef:ab'],
        [ip,is_ip,'Must be a valid ITG IP address, i.e. 128.111.207.200 (<em>Leave <strong>blank</strong> if dynamic.</em>)'],
        [itgid,is_itgid,'Must be a valid ITG ID, i.e. 064001445'],
        [room,is_room,'Must be a valid room number, i.e. 4203G or 1142'],
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
      normalize_room();
      show_ip_picker(form);
      add_dynamic_ip_checkbox();
      form.observe('keyup',submit_toggler);
      ip.observe('change',ip_unavailable_warning);
      //      add_other_to_scope(); //This will probably never be used.
      set_up_toggle_buttons();
      add_dynamic_ip_click_listener();
    }
  };

}();

/* Change layout, style, and UI for savvy browsers. */
var deezy_layout = function() {

  /* private methods */ 
  var set_up_note_previews,add_collapse_expand_all_notes_links,colorize_odd_rows;

  /* Set up note previews that can expand to show the whole note content. */
  set_up_note_previews = function() {
    var notes = deezy_layout.notes;
    notes.expand = function() {
      notes.each(function(note) { if (note.expand) { note.expand(); } });
    };
    notes.collapse = function() {
      notes.each(function(note) { if (note.collapse) { note.collapse(); } });
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
        };
        note.expand = function() {
          last.show();
          note.addClassName('note_expanded');
          note.removeClassName('note_collapsed');
          link.update('&laquo;');
        };
        note.collapse = function() {
          last.hide();
          note.removeClassName('note_expanded');
          note.addClassName('note_collapsed');
          link.update('&raquo;');
        };
        note.collapse();
      }
    });
    add_collapse_expand_all_notes_links();
  };

  add_collapse_expand_all_notes_links = function() {
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

  };

  /* Colorize the odd rows */
  colorize_odd_rows = function() {
    $$('.alt_rows tbody tr:nth-child(odd)').each(function(tr) { tr.addClassName('odd'); });
    $$('.alt_rows tbody tr:nth-child(even)').each(function(tr) { tr.removeClassName('odd'); });
  };
  
  return {
    notes:null,
    init:function() {
      deezy_layout.notes = $$('.notes_col');
      colorize_odd_rows();

      /* If there's an 'entries' table, set up expandable note previews. */
      if ($('entries')) { set_up_note_previews(); }

      deezy_form_layout.init(); // Do the form layout
    }
  };
}();

Event.observe(window,'load',function() {
  deezy_layout.init();
});
