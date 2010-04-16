class EntriesController < ApplicationController

  after_filter :filter_notes, :only => [:index, :show]

  # GET /entries
  # GET /entries.xml
  def index

    #
    # Handle per_page values. Use the parameter if specified. Fall back to a
    # cookie value, then to the default.
    # 

    ppdef = 15 # default value

    if params[:per_page]
      p = params[:per_page]
      if p.downcase == 'all'
        p = 9999999999999
      elsif p.to_i < 1
        p = ppdef
      end 
      @per_page = cookies[:per_page] = p
    elsif cookies[:per_page]
      @per_page = cookies[:per_page]
    else
      @per_page = cookies[:per_page] = ppdef
    end

    # Sort by created_at_date if no search is being performed
    params[:search] = {:order => 'descend_by_created_at'} if params[:search].blank?

    @search = Entry.search params[:search]
    @entries = @search.all.paginate :page => params[:page], :per_page => @per_page

    filter_notes

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
    end
  end

  # GET /entries/1
  # GET /entries/1.xml
  def show
    @search = Entry.search params[:search]
    @entry = Entry.find(params[:id])
    
    filter_notes

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.xml
  def new
    @search = Entry.search params[:search]
    @entry = Entry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @search = Entry.search params[:search]
    @entry = Entry.find(params[:id])
  end

  # POST /entries
  # POST /entries.xml
  def create
    
    # Create integer copy of IP address
    params[:entry][:ip_int] = Entry.ip_as_int params[:entry][:ip]

    @search = Entry.search params[:search]
    @entry = Entry.new(params[:entry])

    respond_to do |format|
      if @entry.save
        flash[:notice] = 'Entry was successfully created.'
        format.html { redirect_to(@entry) }
        format.xml  { render :xml => @entry, :status => :created, :location => @entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.xml
  def update
    
    # Create integer copy of IP address
    params[:entry][:ip_int] = Entry.ip_as_int params[:entry][:ip]

    @entry = Entry.find(params[:id])

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        flash[:notice] = 'Entry was successfully updated.'
        format.html { redirect_to(@entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.xml
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to(entries_url) }
      format.xml  { head :ok }
    end
  end

  def dhcpd_conf
    headers["Content-Type"] = 'text/plain; charset=utf-8'
    render :layout => false
  end

  def dhcpd_leases
    send_file '/home/itgutil/dhcpd.leases', :type => 'text/plain', :disposition => 'inline'
  end

  def free_ips
    headers["Content-Type"] = 'application/json; charset=utf-8'
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    render :layout => false
  end

  private

  #
  # Pass the notes fields through some filters. Useful for adding links.
  #
  def filter_notes
    filters = []
    filters << {:re => /(https?:\/\/\S+)/i, :sub => '<a href=\1>\1</a>'}
    filters << {:re => /\brt:(\d+)\b/i, :sub => '<a href=https://rt.education.ucsb.edu/Ticket/Display.html?id=\1>rt:\1</a>'}
    filters << {:re => /\bwiki:([\S\(\)_]+)/i, :sub => '<a href=http://wiki.education.ucsb.edu/\1>wiki:\1</a>'}
    filters << {:re => /#(\S+)\b/i, :sub => '<a href=/entries?search[order]=&search[mac_or_ip_or_itgid_or_room_or_hostname_or_uid_or_notes_contains]=%23\1>#\1</a>'}

    @entries = [@entry] if @entries == nil
    @entries.each do |e|
      filters.collect { |f| e.notes.gsub! f[:re], f[:sub] }
    end
  end

end
