Remote Meetups News Platform
===================================

This news platform is copied from the [Green Ruby toolset](https://github.com/greenruby/grn-static), with some adaptations and improvements.

The templates
----------------

Templates are located in `views/`. There are 2 main destinations for the templates, the ones intended to be uploaded to mailchimp, and the one used to produce the website.

| template        | description |
|-----------------|-------------|
| rmn.html.erb    | it's the template of the newsletter as it is supposed to be sent via mailchimp. It follows some constraints related to the mailchimp publication system, like the inline css, usage of tables, and such crazy things. |
| rmn.rss.erb     | used to generate the rss file `/feed.rss` |
| rmn.txt.erb     | the txt version of the mailchimp template. html to txt feature in mailchimp is not really reliable, so we generate our txt by ourselves |
| static.haml     | this is the main website template, as used for the website. It will use the css files placed ion `css/` which are a sort of copy of the inline css we have in the newsletter but not totally exact same. |
| template-v1.erb | this is the part, in the website html template, containing the `content` |

The content
---------------

There is 3 type of content:

### the config file

There is a config.yml holding a certain amount of data that is going to be used in all the templates.

### The static pages

Like the `about` page or whatever other page. The build script will take all the markdown files present in that directory and create a `.html` page accordingly in `site/`. The a link to those pages can be added in the main navigation in /views/static.haml`.


### The newsletters

The newsletter is redacted in `yaml` format in `newsletters/rmn.yml`. This file will always be the 'current' working version, unpublished yet. When the `rake generate` task is executed, it will take that yaml file, and create various files:

- `archives/rmn-<number>.yml` which is the archive of that yaml file for later regeneration if needed.
- `html/RMN-<number>.html` is supposed to be uploaded as main html template to mailchimp
- `partials/RMN-<number>.html` is used to generate the website equivalent of the newsletter
- `txt/RMN-001.txt` is the generate text version of the nezsletter, to be uploaded to mailchimp

Note, there are blocs of markdown embedded in the yaml file. For some mysterious reason it needs to have double-linefeeds to work properly. If someone finds a fix, welcome to PR it!

The building commands
------------------------

To be able to modify and generate the content you need to just clone this repo and then

    bundle install --path vendor

Now you can 

    rake

and it will regenerate the content of `site/`, plus the other files described earlier. The default `rake` command (with no argument) will execute the `generate:full` command/task.

    rake deploy           # deploy to gh-pages
    rake generate:all     # re-generate all letters html file
    rake generate:full    # full regeneration
    rake generate:letter  # generate a new letter html file
    rake generate:rss     # make rss feed
    rake generate:web     # updates static website

Publication to Mailchimp
------------------------------

The publication process follow those steps:

- write the yaml file for content, verify it locally
- generate the content locally and verify it
- commit and push the newly generate content
- in mailchimp, go to templates, click on 'upload your own'
- upload `newsletter/html/RMN-001.html`
- verify that all is good, save
- from templates list, select 'create a new campaign' form the template you just uploaded
- fill up the meta-information (title of the campaign, subject of the mail, sending email address, etc)
- next next next
- at the last step, upload the `newsletter/txt/RMN-001.txt` file as a text version for the campaign
- click send, verify your mailbox

Honestly we could use the mailchimp api to automate the process, but I feel this manual process provides the incentive to re-verify and verify again that there is no mistake, visual problem, etc...

Web Deployment
---------------

The `rake deploy` command will take the current version of the `site/` directory to push it in the `gh-pages` branch. Note that the changes in `sites/` have to be committed and push for them to be taken in account.


Help!
-----------------

If you need any guidance in the publication process, feel free to ask Franzé or mose on slack.


License
------------

The code (in `lib/`) is Copyright (c) mose - available under MIT license

The content (all the rest, markdown, yaml, css) is published under [Creative commons CC-BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/) by the [Remote Meetup Team](https://github.com/orgs/remotemeetup/people).

