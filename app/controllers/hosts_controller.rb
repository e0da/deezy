class HostsController < ApplicationController

  after_filter :filter_notes, :only => [:index, :show]

  # GET /hosts
  # GET /hosts.xml
  def index

    #
    # Handle per_page values. Use the parameter if specified. Fall back to a
    # cookie value, then to the default.
    # 

    ppdef = 15 # default value

    if params[:per_page]
      p = params[:per_page]
      if p.downcase == 'all'
        p = 999999999
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

    @search = Host.search params[:search]
    @hosts = @search.all.paginate :page => params[:page], :per_page => @per_page

    filter_notes

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @hosts }
    end
  end

  # GET /hosts/1
  # GET /hosts/1.xml
  def show
    @search = Host.search params[:search]
    @host = Host.find(params[:id])
    
    filter_notes

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @host }
    end
  end

  # GET /hosts/new
  # GET /hosts/new.xml
  def new
    @search = Host.search params[:search]
    @host = Host.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @host }
    end
  end

  # GET /hosts/1/edit
  def edit
    @search = Host.search params[:search]
    @host = Host.find(params[:id])
  end

  # POST /hosts
  # POST /hosts.xml
  def create
    
    # Create integer copy of IP address
    params[:host][:ip_int] = Host.ip_as_int params[:host][:ip]

    @search = Host.search params[:search]
    @host = Host.new(params[:host])

    respond_to do |format|
      if @host.save
        flash[:notice] = 'Host was successfully created.'
        format.html { redirect_to(@host) }
        format.xml  { render :xml => @host, :status => :created, :location => @host }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /hosts/1
  # PUT /hosts/1.xml
  def update
    
    # Create integer copy of IP address
    params[:host][:ip_int] = Host.ip_as_int params[:host][:ip]

    @host = Host.find(params[:id])

    respond_to do |format|
      if @host.update_attributes(params[:host])
        flash[:notice] = 'Host was successfully updated.'
        format.html { redirect_to(@host) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @host.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.xml
  def destroy
    @host = Host.find(params[:id])
    @host.destroy

    respond_to do |format|
      format.html { redirect_to(hosts_url) }
      format.xml  { head :ok }
    end
  end

  def dhcpd_conf
    headers["Content-Type"] = 'text/plain; charset=utf-8'
    render :layout => false
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
    filters << {:re => /\brt:(\d+)\b/i, :sub => '<a href=https://apps.education.ucsb.edu/rt/Ticket/Display.html?id=\1>rt:\1</a>'}
    filters << {:re => /\bwiki:([\S\(\)_]+)/i, :sub => '<a href=http://wiki.education.ucsb.edu/\1>wiki:\1</a>'}
    filters << {:re => /#(\S+)\b/i, :sub => '<a href=/deezy/hosts?search[order]=&search[mac_or_ip_or_itgid_or_room_or_hostname_or_uid_or_notes_contains]=%23\1>#\1</a>'}

    @hosts = [@host] if @hosts == nil
    @hosts.each do |e|
      filters.collect { |f| e.notes.gsub! f[:re], f[:sub] }
    end
  end

end
