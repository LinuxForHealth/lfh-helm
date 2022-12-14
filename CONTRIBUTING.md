## Contributing
To contribute code or documentation, please submit a [pull request](https://github.com/linuxforhealth/lfh-helm/pulls).

Because we're currently configured to do a release each time we merge to main, each PR will need to include the following changes:
1. bump the chart version at https://github.com/linuxforhealth/lfh-helm/blob/main/charts/fhir-server/Chart.yaml#L4
2. replace the changes list in Chart.yaml with whatever changes are included in the PR
3. run helm-docs to generate an updated README and include that with your PR

A good way to familiarize yourself with the codebase and contribution process is
to look for and tackle low-hanging fruit in the [issue tracker](https://github.com/linuxforhealth/lfh-helm/issues).
Before embarking on a more ambitious contribution, please get in touch.

## Communication
Open an [issue](https://github.com/linuxforhealth/lfh-helm/issues) or connect with us through https://chat.fhir.org/#narrow/stream/212434-LinuxForHealth.

## Reviews
The project maintainers use [GitHub reviews](https://github.com/features/code-review) to indicate acceptance.
A change requires approval from one or more maintainers.
Sometimes reviewers will leave a comment "LGTM" to indicate that the change "looks good to me".

## Legal
We use the [Developer's Certificate of Origin 1.1 (DCO)](https://github.com/hyperledger/fabric/blob/master/docs/source/DCO1.1.txt)
to ensure project pedigree.

We ask that, when submitting a patch for review, the developer include a sign-off statement to certify that:
```
       (a) The contribution was created in whole or in part by them and they
           have the right to submit it under the open source license
           indicated in the file; or

       (b) The contribution is based upon previous work that, to the best
           of their knowledge, is covered under an appropriate open source
           license and they have the right under that license to submit that
           work with modifications, whether created in whole or in part
           by them, under the same open source license (unless they are
           permitted to submit under a different license), as indicated
           in the file; or

       (c) The contribution was provided directly to them by some other
           person who certified (a), (b) or (c) and they have not modified
           it.

       (d) They understand and agree that this project and the contribution
           are public and that a record of the contribution (including all
           personal information they submit with it, including their sign-off) is
           maintained indefinitely and may be redistributed consistent with
           this project or the open source license(s) involved.
```

Here is an example Signed-off-by line:

```
Signed-off-by: John Doe <john.doe@example.com>
```

You can include this automatically when you commit a change to your
local git repository using the following command:

```
git commit -s
```
