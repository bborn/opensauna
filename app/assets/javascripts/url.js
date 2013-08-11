var url = function(attributes) {
	for(k in attributes){
		this[k] = attributes[k];
	}

	this.text_for_item = ko.observable(attributes['text_for_item']);
	this.title = ko.observable(attributes['title']);

  this.base_url = attributes['url'].match(/http(s)?:\/\/(www\.)?(.*?)\//)[3];
	this.score = ko.observable(attributes['score']);

  this.generated_classification = ko.observable(attributes['generated_classification']);

  //barffff
  this.classification_class = ko.dependentObservable(function(){
    if (this.generated_classification() && this.generated_classification()["dashboard_"+dashboard_id]){
      clas = this.generated_classification()["dashboard_"+dashboard_id][0];
    } else {
      clas = '';
    }

    if( clas == 'good'){
      return {good: true, bad: false, neutral: false};
    } else if (clas == 'bad' ){
      return {bad: true, good: false, neutral: false};
    } else {
      return {neutral: true, good: false, bad: false};
    }
  }, this);

	this.score_class = function(){
    if(this.score() > 0){
      return {good: true, bad: false, neutral: false};
    } else if (this.score() < 0){
      return {bad: true, good: false, neutral: false};
    } else {
      return {neutral: true, good: false, bad: false};
    }
  };

	this.images = ko.observableArray([]);
	for(i in attributes['images']){
		this.images.push(attributes['images'][i]);
	}

	this.rateGood = function(){
	  this.rate(1);
	}
	this.rateBad = function(){
	  this.rate(-1);
	}
	this.rate = function(arg){
    this.score(this.score() + arg);
	  if(this.score() < 0){
	    viewModel.urls.remove(this);
	  } else {
	    $.mason();
	  }
    $.get('/urls/' + this._id + '/score?dashboard_id='+viewModel.dashboard_id+'&score=' + arg);
	}

	this.isEditing = ko.observable(false);
	this.isNotEditing = ko.dependentObservable(function(){
	  return !this.isEditing();
	}, this);
	this.editButtonText = ko.dependentObservable(function(){
	  return this.isEditing() ? 'Cancel' : 'Edit';
	}, this);

	this.save = function(){
	  this.isEditing(false);
    $.mason();
	}
	this.toggleEdit = function(){
    ed = this.isEditing() ? this.isEditing(false) : this.isEditing(true);
    $.mason();
    return ed;
	}

	this.permalink = ko.observable(window.location.href + 'url/' + this._id);

}
