---
title: "Learning Rust by Building a Http Server"
date: 2024-09-29T00:36:11+02:00
draft: false 
tags: ["rust", "programming"]
---

Hey nobody who is reading this, been a while since the last post, why not make an update about something actually interesting, writing a HTTP server from scratch in rust using only the standard rust library.

## Why?

I have always enjoyed coding, however the hardest part for me was keeping it interesting for myself, because I get distracted pretty quickly. So I usually don't get much enjoyment out excercises or other stuff like that, I like to dive in the deep end as one might say, and either learn to swim or drown.

This particular challenge was inspired by one of my friends, who had due to the recent interaction with C/C++ in education decided to learn to write there own "standard-library", in C++ to learn the language. And ofcourse, I had to prove rust was superior ;). But being honest, I thought it was actually a cool challenge, and when they said they where writing a HTTP server from scratch that actually sounded interesting, so I decided why not try that with rust.

I had previosly had some fun with rust, specifically with the amazing [rustlings](https://github.com/rust-lang/rustlings/) project, between "exercises" I do think rustlings is actually really good, it's not my style which is why I ended up not really using it for long before dropping it. So my previous rust experience was... well non-existant one could say. I knew what the language did and the fundementals but besides that I was new as could be.

## The start

I started by thinking "Why not implement a random number generator", as this sounded like a pretty interesting thing to start with, before I realised how incredibley boring that was for me at the time. Random number generators are super interesting, however I got bored very quickly due to me basically just grabbing from /dev/random, I could have made it more interesting but didn't, so I moved on from that.

Then we have the first commit which actually started with me implementing the HTTP server, specifically this was the base struct the HTTP server used, and still uses to this day. You can find this in the github linked below, but as you can see in the [commit](https://github.com/Stetsed/std-stupid/commit/1acd38248a130a7465b95d1ebd4b16dc9b9998c9), it's... a mess one could say. I would realise later that the naming conventions of rust are quite a bit diffrent to those I had been used to, but let alone from that I hadn't yet really understood how rust errors really worked.

At the time I was using match on all errors, and just panic at basically every error, because it was faster at the time. Until I later realised that if you just use proper errors(I later implemented my own error enum to allow quick and easy handling of more error types), you can just use a question mark to handle a possible error and if you later wanna build around that it's very easy as you just use match statements and then decide from there.

### Sub-String Hell

The first major thing I needed(or did need at the time), was a sub-string finder. Specificially due to how HTTP works I had to be able to parse headers, the first thing in this chain was the HTTP request line. This is the one that has the type of request (GET, POST, PUT etc), the path, and the HTTP version. To be able to parse this I had to be able to find specific parts of the string, so I decided to make a horrible(As I later would realise) sub-string finder, and after some debugging I would use it to be able to parse the first part of the request, although only if the request was of the type GET.

Below is the first version of my sub-string finder, and as you might see it's... bad. Firstly the biggest problem is the usage of arrays and vectors. I found it easier in the beginning to work with vectors because it saved me a headache of having to use references everywhere, which I did for arrays due to them not having a known size at compile time for these types of functions. However in this implementation I am doing the idiotic thing of converting everything to a vector.

For example, when we wanna check if after we know the first charachter matches the entire string matches, instead of just grabbing a slice, we are converting it to a vector which means to do this conversion it needs to get the length, due to vectors having length as part of there struct, which means they get an O(1) for future .len() calls. This isn't needed at all in this case though, and just causes more overhead because firstly we know the length it will have, because it's subStringLength so even if we needed it we wouldn't care.

Secondly, we are doing unneeded compares, specifically we are comparing the first charachter of the sub-string 2 times, as we are comparing i == 0, and in the later compare operation it will also go over the same i == 0 comparison as it's 2 vectors comparing which means it goes over every charachter in sequence.

I would later also create a findSubStringBytes and findSubStringWithString function, which in the end was completley unneeded due to it being much more efficient to just have 1 function, and then if you want to give it a string you just do .as_bytes() to get it in byte form.

```rust
pub fn findSubString(array: Vec<u8>, subString: String) -> Result<u32, subStringError> {
    let subStringAsBytes: Vec<u8> = subString.as_bytes().to_vec();
    let subStringLength = subString.len();
    let mut location: Option<u32> = None;
    for i in 0..(array.len() - 1) {
        if array[i] == subStringAsBytes[0] {
            let compare = array[i..i + subStringLength].to_vec();
            if compare == subStringAsBytes {
                location = Some(i as u32);
                break;
            }
        }
    }
    match location {
        Some(e) => Ok(e),
        None => Err(subStringError {
            source: "Substring has not been found in provided input".to_string(),
        }),
    }
}
```

### Parsing 2, electric boogaloo

So, we had the new sub-string finder function, and for now I would think it's still useful... until much later but we will get to that. After having my sub-string finder I started implementing my parsing logic, most which came in a [commit](https://github.com/Stetsed/std-stupid/commit/1d9ad75aa2df612a1fd63a2cc0e5812030d6cb01) a few days later. This is part of the parsing logic I had implemented.

This part shows the basic process that I was performing, I would take the connectionData(Clone it because I was testing and it was easier), then find the location of a certain charachter or set of charachter. In this case it was to find the H, because we knew everything that came before the H and after the / was part of the path that was requested. We performed the same operation for the method and http version. And at the time we also used a vector, and we "consumed", the vector as we continued with ment we would only read what wasn't taken by another part of the function yet.

The next thing we would do is alot of cleanup, specifically instead of using unwraps like before we switched to using match statements to handle these errors. We also started with the first version of the error enum, in [here](https://github.com/Stetsed/std-stupid/commit/da8fffaccf3078fa8c03223af77b73d962b05d15) it was still called HttpReturnError, but this would later become the StdStupidError which I use in most of the library. This allowed me to have a proper error type return instead of just using the same thing over and over again usually in the form of panics.

We also switched over to using a iterator for the connection, instead of the previous accepting a connection and seeing if it worked. By using the TcpListner iterator it allowed us to not just be frozen by a connection, as if the OS gave a WouldBlock error we would just continue to the next connection and let that deal with itself. The upsides of actually reading documentation is sometimes you just find the exact thing you need.

In this version(which would be changed later), we where also using read_to_end() on our TCPStream, the problem with this is that the TCPStream wouldn't give an end inside of the HTTP header, and as such it would only actually give a response when we ctrl + c'd the test cURL session, as then it would give an EOF and we would actually process it. Later we switched this over to a BufReader, and after that we also switched to a fixed sized static array.

```rust
        // Find the H to know the entire path
        let PathLocation = findSubStringWithBytes(connectionData.clone(), &[0x48]).unwrap();

        let requestPathGiven = str::from_utf8(&connectionData[0..PathLocation as usize - 1])
            .unwrap()
            .to_string();

        connectionData.drain(0..PathLocation as usize);
```

### Old habits, die hard

The best example of me having to learn the rust way of doing something instead of the C++ way was the example of getter's and setters. The way I learned C++ was that you never made parts of structs public unless you absolutley had no choice, instead you implemented a getter for that variable to get it. You can see me implementing this in a [commit](https://github.com/Stetsed/std-stupid/commit/b5b6a6559109f03bf4226d1ecbe31c16bcc4b91a#diff-2388a20a92c86e0df4512d3af2075f4f3d3a3a4822fc424930fc29f2cfb3a26fR103). Where in rust there is no real reason not to just make a part of a struct public because you are forced into memory safety with the borrow checker regardless.

```rust
    pub fn getServerPort(&self) -> u16 {
        self.Port
    }
    pub fn getServerIP(&self) -> Ipv4Addr {
        self.ListeningAddress
    }
```

I also realized that rust had a native concept of multi-project repositories, in the form of workspaces. I liked the idear because I find it nice to be able to split stuff into there own sub-project, without having to use things like git-submodules or similar, so in a later [version](https://github.com/Stetsed/std-stupid/commit/e8a91797e0c0012a293a4e283452980bfb92219d) I switched over to having each part of the "stupid" library, be in it's own module, which ment I could split my errors section from my http section and so forth.

Doing this also gave me a better understanding of what Cargo packages and crates actually are, previosly I had the impression they where more like compiled libraries that exposed themselves via a ABI, but I realised that they are more like the equivalant of git bundles, you download them and then Cargo compiles them with you're project so you can use them.

### Cleanup crew on the git repository

While I was coding the HTTP server I was also reading alot, one of the best things I found where the rust books, I had known of them before but because of my short interest never really took a good look at them, but I realised they had alot of really cool and interesting content. The 2 books I was really fond of where ofcourse the [rust book](https://doc.rust-lang.org/stable/book/), and for my toe dipping into async rust the [async-rust](https://rust-lang.github.io/async-book/) book.

The biggest commit where I tried to dive a bit into the "better" way of doing stuff was the [commit](https://github.com/Stetsed/std-stupid/commit/84a8d8e89a20628be4f21087927806756576745e) where I went through and fixed quiet a few "not best practice" rust things, firstly this was documentation. I had previosly used doxygen as my documentation generator but the effort it took to setup was more than my 2 braincells could handle, so I never really documented stuff. But then I realised rust has a really great "built-in" document generator, in the form of rustdoc.

I also started switching over to the rust naming conventions, primarily with the use of the [RFC](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md) which establishes this for rust. Honestly I also found it interesting reading the discussion about this subject in the forums when I was looking for it. And although it did(and does) take some getting used to, it definetley does increase the uniformity of the code that I made which is always nice to have.

I also finally started to switch over from Vec<u8> to &[u8] because as said earlier I was using Vec<u8> when it was not needed and was just wasting effort, although for now I would still be using vectors alot even when not needed. I also started switching away from clones alot because I started to get a better grasp of how the rust borrow checker worked and how it functioned, and was actually able to use it correctly to fix my issues instead of just "Throw .clone() at it then it doesn't complain".

### HTTP server working? Impossible

By [this](https://github.com/Stetsed/std-stupid/commit/b2e8cdfb9343526192b3effdaf04d14a0d5ad0ce) time my HTTP server was working, or well in basics it was. It was able to recieve a request, parse it although at this time pretty inefficiently and unreadable for a coder who has more than 1 braincell. And it was able to respond to a request, either with a "debug" response which just echoed the headers it got back which where just stored in a hashmap on the server side. Or being able to serve a file with a reader and then serving that back to the client with the body.

I also started looking at async rust, I thought it was interesting and looked at possibly implementing it to be used within the server. However let's just say it didn't go according to plan, I had it working for rougly 10 minutes before I broke it, and was not able to get it back to a working state. You can also see in the commits that I added it [1](https://github.com/Stetsed/std-stupid/commit/6f568ce69342937157e6bc7eac52ffdc20a96af1) day, and removed it the [next](https://github.com/Stetsed/std-stupid/commit/47744e47226a96adb5058a1a46a80dc507527f6e) day. And this is a reminder to always commit stuff when it works and then continue tweaking on it, because otherwise you might hate yourself the next day trying to figure out if you where high, drunk or both when writing the code.

After the disaster that was me trying to implement async rust, I decided to take another look at one of the most scuffed parts of the entire code, this being the parsing. It was so bad that I decided to completley rewrite it, which I did the day after the async attempt, boredom sure is a powerful creature. I completley [deleted](https://github.com/Stetsed/std-stupid/commit/e44482640f8c369db2a9054b923e484f4620ba38) the old parsing code and rewrote it from scratch. I started by switching away from my sub-string finder, remember me saying earlier it was pretty useless for this case? Well this is why, I was only using it to find 1 charachter and then splitting the string.

So in the new code I decided to take a diffrent approach, as you can see bellow. I started by switching from my previous headache inducing search for the CLRF charachter to using the .lines function on my raw connection data, which was fine for me because it gave me all I cared about which was each line. The later lines are easy as we just find the : inside and split it there, the first is the header, the second is the content.

However for the first instace I have to grab multiple data points out of the 1 line, so I have to do a bit more parsing. So I ended up with a pattern like the one bellow. We are continuing the "Consume", parsing model, which means we split the string at a certain point, and then pass on the rest as you can see below. Here we are finding the / inside of the string, because we know that which is before the / has to be the rest type, as the length does not matter because it will always be (Type) /(Path), so if we find the slash we know the type.

We them simply repeated this for the others, for the path we just found the H and split it on that, because between that and the / is the full path we want, rinse and repeat for the http version.

At this time I also started using debug_assertions, I realised how useful these where as it ment I could just leave my debug statements in, but not worry about them with a --release build test, so I just used --release as a "end-to-end" test, and normal build as a debug step by step build.

With this new parser however, we got some major improvements, we went from rougly 40k requests per second to over 60k, and a bandwith of 12Gb from 7Gb, for the same actual output that we are getting.

```rust
            (http, rest) = unwrapped
                .as_bytes()
                .split_at_checked(
                    unwrapped
                        .find('/')
                        .ok_or_else(|| HttpServerError::new("Failed to find /"))?,
                )
                .ok_or_else(|| {
                    HttpServerError::new("Failed to split string... should be impossible")
                })?;
```

### It's threading time

The last major thing I did up to this point in the project(More to come soonTM) is the thread pool, instead of using a pre-made one I decided to follow the rust book on implementing my own. You can find this in chapter [20.2](https://doc.rust-lang.org/book/ch20-02-multithreaded.html), it does a great job of explaining how this works and what you are doing instead of just giving you a solution to the problem, and it helped me learn alot.

Also a channel I could very much recommend is [The Rusty Bits](https://www.youtube.com/@therustybits), in this project it didn't have any direct impact however the explaining on an embedded level helped me understand core concepts quiet a bit because he tries to explain them from the bottom up, even going from nothing to an async runtime.. something I might want to do in the future over my current threadpool only implementation loop.

## In the end

In the end, I very much enjoy/enjoyed my time writing with rust, I have started to understand the language and honestly also more programming in general, applying the rust knowledge to my other languages like C/C++ where I need them. I have continued writing stuff, currently I am working on implementing web-sockets support on the server, we will see if I finish that or if it joins the pile of un-finished projects.

I hoped you enjoyed reading this, idk why I wrote this it's currently rougly 2 in the morning and I was planning to go to bed... and now I am 3000 words into writing this post. So I hoped you enjoyed it, and have a lovely week/weekend/afternoon/morning/night.

## Links

- Github repository of the std-stupid project: <https://github.com/Stetsed/std-stupid>
- Rust book: <https://doc.rust-lang.org/stable/book/>
- Rust async book: <https://rust-lang.github.io/async-book/>
- Cool rust embedded videos: <https://www.youtube.com/@therustybits>
