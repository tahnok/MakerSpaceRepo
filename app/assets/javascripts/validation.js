function validation(){
	var ret = true;
	var title = $("input#repository_title");
	var github = $("input#repository_github");
	$('span.form-error.repo-form').remove();
	var span = $('<span>').addClass('form-error repo-form');


	if(title.val().length === 0 ){
		span.text("Repository name is required.");
		$('input#repository_title').before(span);
		ret = false;
	}

	var span = $('<span>').addClass('form-error repo-form');

	if(photoFiles.length === 0 ){
		span.text("At least one photo is required.");
		$('div.repo-image').before(span);
		ret = false;
	}

	var span = $('<span>').addClass('form-error repo-form');

	if( github.val().length === 0 && instructableFiles.length !== 0 ){
		span.text("Github repository name required.");
		$('input#repository_github').before(span);
		ret = false;
	}

	return ret;	
}