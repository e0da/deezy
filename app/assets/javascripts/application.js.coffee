attach_validation = (validation) ->
  field = $("##{validation.id}")
  field.data 'sanitize', validation.sanitize
  field.data 'valid', validation.valid
  field.data 'help', validation.help

trim = (field) ->
  field.val(field.val().trim())

sanitize = (field) ->
  field.val field.data('sanitize').call(field.val()) if field.data('sanitize')

valid = (field) ->
  clear_warning(field)
  if field.data('valid')
    field.val().match field.data('valid')
  else
    true

clear_warning = (field) ->
  field.css(border: '')
  $("##{field.attr('id')}_warn").remove()

warn = (field) ->
  field.css(border: '1px solid #c00')
  warning = $("<p id=#{field.attr 'id'}_warn class=field_warning>").text field.data 'help'
  field.after(warning) if field.data('help')
  warning.css {
    width: '200px'
    padding: '1em'
    background: '#fee'
    marginLeft: '-230px'
    marginTop: '-40px'
    border: '1px solid #c00'
    borderRadius: '5px'
  }
    
  
  console.error field.data('help') if field.data('help')

$ ->

  # form stuff
  #
  if $('#ip_picker').length > 0

    # IP address picker
    #
    $.getJSON '/deezy/freeips.json', (data) ->
      pools = []
      ip_picker = $('#ip_picker')
      ip_picker.click (event) ->
        clicked = $(event.target)
        $('#host_ip').hide().val(clicked.text()).change().fadeIn('fast') if $(clicked).is 'li'

      for pool in data
        list = {}
        pools.push list
        list.pool = pool.pool
        list.ips = $('<ul>')

        for ip in pool.ips
          li = $("<li>#{ip}</li>")
          list.ips.append li

      form = $('form.edit_host, form.new_host')
      select = $('<select>').change ->
        i = $(this).find(':selected').index()
        ip_picker.find('.list').empty().append pools[i].ips

      for pool in pools
        select.append $("<option>#{pool.pool}</option>")

      ip_picker.prepend select
      ip_picker.find('.list').append pools[0].ips

    # form validation
    #
    validations = [
      id: 'host_mac'
      sanitize: -> this.toLowerCase().replace(/[^a-f\d]/g, '').replace(/(..)(..)(..)(..)(..)(..)/, '$1:$2:$3:$4:$5:$6')
      valid: /^([a-f\d]{2}:){5}[a-f\d]{2}$/
      help: "A valid MAC address is 12 hexadecimal (0-9A-F) characters. Case and punctuation don't matter."
    ,
      id: 'host_ip'
      valid: /^(((\d{1,3})\.){3}\d{1,3}|)$/
      help: "You probably want to pick an IP address from the list on the right"
    ,
      id: 'host_itgid'
      valid: /^\d{2}[48]00\d{4}$/
      help: "An ITG ID is the 2 digit year, 400 or 800, then 4 digits, like 084004432."
    ,
      id: 'host_room'
      sanitize: -> this.toUpperCase()
      valid: /^\d{4}[A-Z]?$/
      help: "A room number is four digits (optionally followed by a letter)."
    ,
      id: 'host_hostname'
      sanitize: -> this.toLowerCase()
      valid: /^[a-z][a-z\d-]+$/
      help: "A hostname must start with a letter and can contain letters, numbers, and an dash (-)."
    ,
      id: 'host_uid'
      sanitize: -> this.toLowerCase()
      valid: /^.+$/
      help: "Enter the user's UID."
    ,
      id: 'host_notes'
    ]

    for validation in validations
      field = attach_validation validation
      field.change ->
        field = $(this)
        trim(field)
        sanitize(field)
        warn(field) unless valid(field)
