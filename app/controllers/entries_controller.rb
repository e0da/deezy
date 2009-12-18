class EntriesController < ApplicationController

  # GET /entries
  # GET /entries.xml
  def index
    @search = Entry.search params[:search]
    @entries = @search.all.paginate :page => params[:page], :per_page => 21

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
    end
  end

  # GET /entries/1
  # GET /entries/1.xml
  def show
    @search = Entry.search params[:search]
    @entry = Entry.find_by_hostname(params[:id])

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
    @entry = Entry.find_by_hostname(params[:id])
  end

  # POST /entries
  # POST /entries.xml
  def create
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
    @entry = Entry.find_by_hostname(params[:id])

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
    @entry = Entry.find_by_hostname(params[:id])
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

end
