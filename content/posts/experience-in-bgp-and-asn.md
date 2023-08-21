---
title: "Experience in Bgp and Asn"
date: 2023-08-06T08:50:11+02:00
draft: true
---

Hey everybody, it's been a while and alot has changed. Recently I have started going into the world of BGP and the network administration used in the world. You might have seen an earlier post of mine which related to DN42, which let's you try technologie such as BGP in an experience similar to the global network but not having to jump through as many hoops.

But I recently decided to take the step and get my own ASN and IP range. I have been using it for a while now and I have to say it is a really cool experience. I have been using it to learn more about BGP and how it works. I have also been using it to learn more about the network administration.

Today I will go through the steps I (as a minor) had to go through to acquire an ASN and IP range from the RIPE RIR which is the RIR that functions in Europe, the middle east and parts of central asia. I hope this will inspire more young homelabbers to go through the process(assuming they have the willingness to learn) and get their own ASN and IP range.

Be aware that this is me sharing my experience and the process might be diffrent for you, and as you are playing with pretty advanced stuff you should be aware that it will require alot of learning before you try to do anything on the actual internet. This will not be an image tutorial as my others and will mostly be text.

## Summary of the process

* Create a RIPE NCC Access Account, and make the required objects inside of the RIPE database.
* Find a LIR which allows co-signing of the contract by a legal guardian.
* Submit the required documents to the LIR.
* Wait for the LIR to approve the request.
* Wait for RIPE NCC to get to the request and verify your ID via iDenfy.
* Assuming all went correct accept the request and register the ASN.

So now that we have a summary how about we get more into the details.

## The Process

### Step 1: Create a RIPE NCC Access Account

Firstly we will want to head over to [RIPE NCC](https://apps.db.ripe.net/db-web-ui/query) and then at the top right go ahead and make an account with your details. Next click on "Create an object", firstly we will want to go ahead and create a person and maintainer pair, go ahead and click on create and then we will want to fill it in. MNTER can be anything you want ending in -MNT, I went with my legal name and then -MNT. The person object is where you will put your details, I went with my legal name and then my address. You must also add a phone number. Be aware all details you enter in here must be accurate and if they are not you might either not be approved or have your stuff cancelled at a later date.

So, we have created a MNT object, next we will want to go ahead and create an organization. Leave the organisation field as is.
