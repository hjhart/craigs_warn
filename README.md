Okay, so the craigslist gem that is bundled with this only works if you use ruby 1.8.7.

It also only works (due to improper dependencies) if you install nokogiri and html entities manually

	 gem install bundler
	 bundle
	 gem install htmlentities --version=4.0
	 gem install nokogiri --version=1.4.4

Copy the prowl template and add your API key

	cp prowl.template.yml prowl.yml
	
Install in yer crontab:

`0,5,10,15,20,25,30,35,40,45,50,55 * * * * /bin/bash -l -c 'cd ~/Sites/craigs_warn && ruby warner.rb >> /dev/null 2>&1'`