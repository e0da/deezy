// DO NOT MODIFY this file, auto-generated from all js.coffee files in ./app/assets/javascripts

// compiled ./app/assets/javascripts/application.js.coffee 
(function() {

  $(function() {
    if ($('#ip_picker').length > 0) {
      return $.getJSON('/deezy/freeips.json', function(data) {
        var form, ip, ip_picker, li, list, pool, pools, select, _i, _j, _k, _len, _len2, _len3, _ref;
        pools = [];
        ip_picker = $('#ip_picker');
        ip_picker.click(function(event) {
          var clicked;
          clicked = $(event.target);
          if ($(clicked).is('li')) return $('#host_ip').val(clicked.text());
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
    }
  });

}).call(this);

