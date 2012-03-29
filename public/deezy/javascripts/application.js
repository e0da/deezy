// DO NOT MODIFY this file, auto-generated from all js.coffee files in ./app/assets/javascripts

// compiled ./app/assets/javascripts/application.js.coffee 
(function() {

  $(function() {
    var pools;
    if ($('#ip_picker').length > 0) {
      pools = [];
      return $.getJSON('/deezy/freeips.json', function(data) {
        var ip, ip_picker, li, list, pool, _i, _j, _len, _len2, _ref;
        ip_picker = $('#ip_picker');
        ip_picker.click(function(event) {
          var el;
          el = $(event.target);
          if ($(el).is('li')) return $('#host_ip').val(el.text());
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
        return $(function() {
          var form, pool, select, _k, _len3;
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
      });
    }
  });

}).call(this);

