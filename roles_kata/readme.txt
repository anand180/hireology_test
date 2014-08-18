We have a user table, an organization table, and a role table that serves as a join table between user and organization. Users can be of 3 types (organization, child_organization, root_organization),
and this the tiering is checked in the tests.

I used a null db adapter (see gemfile) to prevent the tests from hitting the DB to comply with the desire to test the logic without a database while still keeping this
in rails. This was pretty fun! I think, though, that a better way to do it would have been to move the logic out of the models and into some service object and then test
that logic and just mock the models.

There are a few things that I did not do:

1) I didn't spend any time reducing the number of potential queries. When finding a role for a user, for example, we can make two queries sometimes instead of just 1.

2) I didn't put any basic validations in. I validated the relationship between org types (in a sort of ugly way), but didn't validate that we set the type to only the
one of the valid ones, for example.

3) I didn't deal with transactions or locking or anything like that.

4) I didn't really flesh out the user model. Probably it's organizations relation should have excluded orgs that it had the denied role for, or at least
there should be a method for that.
