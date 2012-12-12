class TitlesController < ApplicationController
  @@BUCKET = "videoguru"
  # before_filter :run_before, :except => [:index, :show, :new, :edit, :destroy, :add_to_cart, :get_cart, :clear_cart, :view_cart]
  before_filter :run_before, :except => [:index, :show, :new, :edit, :destroy]
  
  def run_before
    params[:title][:movie_name] = params[:title][:movie_name].humanize.titleize
	  params[:title][:director] = params[:title][:director].humanize.titleize
  end
  
  # GET /titles
  # GET /titles.xml
  def index
    @titles = Title.all
	# @title = Title.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @titles }
    end
  end

  # GET /titles/1
  # GET /titles/1.xml
  def show
    puts "**************************"
		puts params[:id]
		@title = Title.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @title }
    end
  end

  # GET /titles/new
  # GET /titles/new.xml
  def new
    @title = Title.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @title }
    end
  end

  # GET /titles/1/edit
  def edit
		@title = Title.find(params[:id])
  end

  # POST /titles
  # POST /titles.xml
  def create
    @title = Title.new(params[:title])
    
  	fileUp = params[:upload]
    orig_filename =  fileUp['image_file'].original_filename
    filename = sanitize_filename(orig_filename)
    AWS::S3::S3Object.store(filename, fileUp['image_file'].read, @@BUCKET, :access => :public_read)
    imageurl = AWS::S3::S3Object.url_for(filename, @@BUCKET, :authenticated => false)
	@title.image_url = imageurl
    
    orig_filename =  fileUp['video_file'].original_filename
    filename = sanitize_filename(orig_filename)
    AWS::S3::S3Object.store(filename, fileUp['video_file'].read, @@BUCKET, :access => :public_read)
    videourl = AWS::S3::S3Object.url_for(filename, @@BUCKET, :authenticated => false)

    @title.video_url = videourl

	  # create_author(params[:q],params[:r])
	  # if @author != nil
		respond_to do |format|
			if @title.save
				# @author.titles << @title unless @author.titles.include? @title
				# @author = nil
				format.html { redirect_to(@title, :notice => 'Title was successfully created.') }
				# format.js
				format.xml  { render :xml => @title, :status => :created, :location => @title }
			else
				format.html { render :action => "new" }
				# format.js { render :action => 'create_error' }
				format.xml  { render :xml => @title.errors, :status => :unprocessable_entity }
			end
		end
	# else
	  # respond_to do |format|
	    # format.html { render :action => "new" }
		# correc the line below
		# format.xml { render :xml => {@author=>["Author name is not valid"]}, :status => :unprocessable_entity }
	  # end
	# end
  end

  # PUT /titles/1
  # PUT /titles/1.xml
  def update
    @title = Title.find(params[:id])
    # create_author(params[:q],params[:r])

    # if @author != nil
	  respond_to do |format|
			if @title.update_attributes(params[:title])
		  	# @author.titles << @title unless @author.titles.include? @title
				# if params[:checks] != nil
					# params[:checks].each do |s|
						# if @title.authors.count > 1
								# @title.authors.delete(Author.find_by_id(s))
						# end
					# end
				# end
		    # @author = nil
				format.html { redirect_to(@title, :notice => 'Title was successfully updated.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @title.errors, :status => :unprocessable_entity }
			end
	  end
	  # else
			# respond_to do |format|
				# flash.now[:error] = 'Author name not valid'
				# respond_to do |format|
					# format.html { render :action => "edit" }
				# end
			# end
		# end
  end

  def destroy
	@title = Title.find(params[:id])
	AWS::S3::S3Object.find(@title.image_url.gsub("http://s3.amazonaws.com/videoguru/",""), @@BUCKET).delete
	AWS::S3::S3Object.find(@title.video_url.gsub("http://s3.amazonaws.com/videoguru/",""), @@BUCKET).delete
    @title.destroy


    respond_to do |format|
      format.html { redirect_to(titles_url) }
      format.xml  { head :ok }
    end
  end
  
  private 
      def sanitize_filename(file_name)
        just_filename = File.basename(file_name)
        just_filename.sub(/[^\w\.\-]/,'_')
      end
  
end