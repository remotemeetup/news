Remote Meetups News Platform
===================================

This news platform is copied from the Green Ruby toolset, with some adaptations.

The templates
----------------

Templates are located in `views/`. There are 2 main destinations for the templates, the ones intended to be uploaded to mailchimp, and the one used to produce the website.

| template        | description |
| rmn.html.erb    | it's the template of the newsletter as it is supposed to be sent via mailchimp. It follows some constraints related to the mailchimp publication system, like the inline css, usage of tables, and such crazy things. |
| rmn.rss.erb     | used to generate the rss file `/feed.rss` |
| rmn.txt.erb     | the txt version of the mailchimp template. html to txt feature in mailchimp is not really reliable, so we generate our txt by ourselves |
| static.haml     | this is the main website template, as used for the website. It will use the css files placed ion `css/` which are a sort of copy of the inline css we have in the newsletter but not totally exact same. |
| template-v1.erb | this is the part, in the website html template, containing the `content` |

The content
---------------

There is 2 type of content:

### The static pages

Like the `about` page or whatever other page. The buikld script will take all the markdown files present in that directory and create a `.html` page accordingly in `site/`. The a link to those pages can be added in the main navigation in /views/static.haml`.


### The newsletters

The newsletter is redacted in `yaml` format in `newsletters/rmn.yml`. This file will always be the 'current' working version, unpublished yet. When the `rake generate` task is executed, it will take that yaml file, and create various files:

- `archives/r,m-<number>.yml` which is the archive of that yaml file for later regeneration if needed.
- `html/RMN-<number>.html` is supposed to be uploaded as main html template to mailchimp
- `partials/RMN-<number>.html` is used to generate the website equivalent of the newsletter
- `txt/RMN-001.txt` is the generate text version of the nezsletter, to be uploaded to mailchimp

The building commands
------------------------

To be able to modify and generate the content you need to just clone this repo and then

    bundle install --path vendor

Now you can 

    rake

and it will regenerate the content of `site/`, plus the other failes described earlier. The default `rake` command (with no argument) will execute the `generate` command/task.

    rake deploy           # deploy to gh-pages
    rake generate:all     # re-generate all letters html file
    rake generate:full    # full regeneration
    rake generate:letter  # generate a new letter html file
    rake generate:rss     # make rss feed
    rake generate:web     # updates static website


Deployment
---------------

The `rake deploy` command will take the current version of the `site/` directory to push it in the `gh-pages` branch. Note that the changes in `sites/` have to be committed and push for them to be taken in account.


Help!
-----------------

If you need any guidance in the publication process, feel free to ask Franzé or mose on slack.
