(function() {
  var attach_validation, clear_warning, sanitize, trim, update_copyright_year, valid, validate, warn;
  attach_validation = function(validation) {
    var field;
    field = $("#" + validation.id);
    field.data('sanitize', validation.sanitize);
    field.data('valid', validation.valid);
    return field.data('help', validation.help);
  };
  validate = function(field) {
    trim(field);
    sanitize(field);
    if (!valid(field)) {
      return warn(field);
    }
  };
  trim = function(field) {
    return field.val(field.val().trim());
  };
  sanitize = function(field) {
    if (field.data('sanitize')) {
      return field.val(field.data('sanitize').call(field.val()));
    }
  };
  valid = function(field) {
    clear_warning(field);
    if (field.data('valid')) {
      return field.val().match(field.data('valid'));
    } else {
      return true;
    }
  };
  clear_warning = function(field) {
    field.css({
      border: ''
    });
    return $("#" + (field.attr('id')) + "_warn").remove();
  };
  warn = function(field) {
    var warning;
    field.css({
      border: '1px solid #c00'
    });
    warning = $("<p id=" + (field.attr('id')) + "_warn class=field_warning>").text(field.data('help'));
    if (field.data('help')) {
      field.after(warning);
    }
    warning.hide().fadeIn('fast');
    $(window).resize(function() {
      return warning.css({
        top: "" + (field.offset().top - 10) + "px",
        left: "" + (field.offset().left - warning.width() - 25) + "px"
      });
    });
    return $(window).resize();
  };
  update_copyright_year = function() {
    var listed_year, this_year;
    this_year = (new Date()).getFullYear();
    listed_year = $('#copyright_year').text().trim();
    if (this_year > listed_year) {
      return $('#copyright_year').html("" + listed_year + "—" + this_year);
    }
  };
  $(function() {
    var field, validation, validations, _i, _len;
    update_copyright_year();
    if ($('#ip_picker').length > 0) {
      $.getJSON('/deezy/freeips.json', function(data) {
        var form, ip, ip_picker, li, list, pool, pools, select, _i, _j, _k, _len, _len2, _len3, _ref;
        pools = [];
        ip_picker = $('#ip_picker');
        ip_picker.click(function(event) {
          var clicked;
          clicked = $(event.target);
          if ($(clicked).is('li')) {
            return $('#host_ip').hide().val(clicked.text()).change().fadeIn('fast');
          }
        });
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          pool = data[_i];
          list = {};
          pools.push(list);
          list.pool = pool.pool;
          list.ips = $('<ul>');
          _ref = pool.ips;
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            ip = _ref[_j];
            li = $("<li>" + ip + "</li>");
            list.ips.append(li);
          }
        }
        form = $('form.edit_host, form.new_host');
        select = $('<select>').change(function() {
          var i;
          i = $(this).find(':selected').index();
          return ip_picker.find('.list').empty().append(pools[i].ips);
        });
        for (_k = 0, _len3 = pools.length; _k < _len3; _k++) {
          pool = pools[_k];
          select.append($("<option>" + pool.pool + "</option>"));
        }
        ip_picker.prepend(select);
        return ip_picker.find('.list').append(pools[0].ips);
      });
      validations = [
        {
          id: 'host_mac',
          sanitize: function() {
            return this.toLowerCase().replace(/[^a-f\d]/g, '').replace(/(..)(..)(..)(..)(..)(..)/, '$1:$2:$3:$4:$5:$6');
          },
          valid: /^([a-f\d]{2}:){5}[a-f\d]{2}$/,
          help: "A valid MAC address is 12 hexadecimal (0-9A-F) characters. Case and punctuation don't matter."
        }, {
          id: 'host_ip',
          valid: /^(((\d{1,3})\.){3}\d{1,3}|)$/,
          help: "You probably want to pick an IP address from the list on the right"
        }, {
          id: 'host_itgid',
          valid: /^\d{2}[48]00\d{4}$/,
          help: "An ITG ID is the 2 digit year, 400 or 800, then 4 digits, like 084004432."
        }, {
          id: 'host_room',
          sanitize: function() {
            return this.toUpperCase();
          },
          valid: /^\d{4}[A-Z]?$/,
          help: "A room number is four digits (optionally followed by a letter)."
        }, {
          id: 'host_hostname',
          sanitize: function() {
            return this.toLowerCase();
          },
          valid: /^[a-z][a-z\d-]+$/,
          help: "A hostname must start with a letter and can contain letters, numbers, and an dash (-)."
        }, {
          id: 'host_uid',
          sanitize: function() {
            return this.toLowerCase();
          },
          valid: /^.+$/,
          help: "Enter the user's UID."
        }, {
          id: 'host_notes',
          valid: /^.+$/,
          help: "The Notes field is required. Give a brief description of this host."
        }
      ];
      for (_i = 0, _len = validations.length; _i < _len; _i++) {
        validation = validations[_i];
        field = attach_validation(validation);
        field.change(function() {
          return validate($(this));
        });
      }
      return $('.new_host, .edit_host').submit(function(e) {
        $(this).find('input, textarea').change();
        if ($('.field_warning').length > 0) {
          return e.preventDefault();
        }
      });
    }
  });
}).call(this);
