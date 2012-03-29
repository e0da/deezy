$ ->

  # form stuff
  #
  if $('#ip_picker').length > 0

    pools = []

    # IP address picker
    #
    $.getJSON '/deezy/freeips.json', (data) ->
      ip_picker = $('#ip_picker')
      ip_picker.click (event) ->
        el = $(event.target)
        $('#host_ip').val(el.text()) if $(el).is 'li'
      for pool in data
        list = {}
        pools.push list
        list.pool = pool.pool
        list.ips = $('<ul>')
        for ip in pool.ips
          li = $("<li>#{ip}</li>")
          list.ips.append li
      $ ->
        form = $('form.edit_host, form.new_host')
        select = $('<select>').change ->
          i = $(this).find(':selected').index()
          ip_picker.find('.list').empty().append pools[i].ips
        for pool in pools
          select.append $("<option>#{pool.pool}</option>")
        ip_picker.prepend select
        ip_picker.find('.list').append pools[0].ips
