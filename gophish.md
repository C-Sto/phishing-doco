# Some notes about Gophish
---
## Setting up Gophish
*This is pretty gross. You can make it nicer by symlinking a bunch of stuff.*

**You'll need to make a few adaptions to the following because you will have a different domain**
### A video of everything below:
[![Phisherooni](https://img.youtube.com/vi/v7TGMhxjl0k/0.jpg)](https://www.youtube.com/watch?v=v7TGMhxjl0k)

##### Configuring your environment
###### Setting up golang
- `apt-get update && apt-get -y upgrade && apt-get -y install golang`
- `mkdir ~/golang`
- `echo export GOPATH=\"/root/golang\" >> ~/.bashrc`
- `echo export PATH=\"\$GOPATH:\$PATH\" >> ~/.bashrc`
- `source ~/.bashrc`
##### Building Gophish
- `go get github.com/gophish/gophish`
- `cd $GOPATH/src/github.com/gophish/gophish/src`
- `go build`
- You should now have a binary (`gophish`) in the current directory

##### Configurating Gophish
Config: `$GOPATH/src/github.com/gophish/gophish/config.json`
###### Certificate stuff (generate certs)
- `apt-get -y install letsencrypt`
- `letsencrypt certonly --manual -d acme.net --register-unsafely-without-email`
###### Make certs work with Gophish
-  Change `"cert_path"` point to `/etc/letsencrypt/live/acme.net/cert.pem`
-  Change `"key_path"` point to `/etc/letsencrypt/live/acme.net/privkey.pem`
###### Make the gophish admin page accessible externally (no time for X forwarding)
- Change `127.0.0.1` to your external IP (or `0.0.0.0` lol): `sed -i 's/127.0.0.1/0.0.0.0/g' $GOPATH/src/github.com/gophish/gophish/config.json`
- While you're here, make the phishing server listen on 443 instead of 80
##### run it?
`./gophish &` - by default, the admin page can be accessed at port 3333 with `admin:gophish`

## Using Gophish
### SMTP relays
If you want to send emails that look somewhat legitimate, you should probably use an SMTP relay. Two popular SMTP relay services are [Sendgrid](https://sendgrid.com) and [SMTP2GO](https://smtp2go.com). They're trivial to set up. Ask around, someone may already have an account ready to go.
Once you have an account, you will need an API key to put into Gophish. So... get one of those.

### Workflow (I guess???????)
##### Users & Groups
Put your victims in here. You can also import a bunch of them, but your .csv headers have to be as follows: `First Name,Last Name,Email,Position`. If it doesn't work, copy the data into a plaintext document instead of using Excel. There's some dumb `\CR\LF` junk that Gophish doesn't like. ¯\\\_(ツ)_/¯

##### Email Templates
Pretttty much as it says. Email templates to send. You can import an email by clicking on the 'Import Email' button when creating a template. You can personalise emails using the variable reference below.

##### Landing Pages
Simply, this is the page that a victim will visit, allowing you to harvest their sweet, sweet creds. You can clone a site by clicking on 'Import Site' when you create a new Landing Page. I'd recommending adding in `title` and `alt` tags to links and images. MailGuard drops the score of emails without it and subsequently, your mail won't be delivered. You can personalise landing pages by using the variable reference below.

##### Sending Profiles
This is where you set up your sender you would like to impersonate. You also need to provide your SMTP relay API key when creating a sending profile. I'd recommend sending a test email just to make sure the your relay works as expected and that your sending appears how you want.

##### Campaigns
Once you have all of that set up, you're good to go! Create a campaign, input the domain name of your phishing server, and schedule it. I mean, probably send a test email first.
Keep in mind that scheduling uses the time on **your** device and not the server.

##### Variable reference
| **Variable** | **Reference** |
|--------------|------------------|
| {{.FirstName}} | The target's first name |
| {{.LastName}} | The target's last name |
| {{.Position}} | The target's position |
| {{.Email}} | The target's email address |
| {{.From}} | The spoofed sender |
| {{.TrackingURL}} | The URL to the tracking handler |
| {{.Tracker}} | An alias for `<img src=" {{.TrackingURL}} "/>` |
| {{.URL}} | The phishing URL |
------------------------------
