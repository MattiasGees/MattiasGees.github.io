---
layout:     post
title:      "Software Supply Chain Security"
subtitle:   "Start of your journey with sigstore, syft and OCI registries"
date:       2022-10-16 15:00:00
author:     "Mattias Gees"
background: "/img/keylock.jpg"
---

# Software Supply Chain Security

Besides a few blog posts on my employer's [blog](https://www.jetstack.io/blog/google-threat-horizons-report/), I haven’t blogged in a long time, my last post on here was over 4 years ago.  I plan to start again and lower the bar of entry, I am forcing myself to have less polished posts to be published and be okay with it.

For some time I have been very interested in the Software Supply Chain Security space. It reminds me a bit of the early days of Kubernetes, where new tooling was popping up almost every week. I have been following closely what is happening with [SLSA](https://slsa.dev) and [Sigstore](https://www.sigstore.dev) especially. Over the weekend I have been toying a bit with GitHub Actions and securing the supply chain.

## Github Actions

For a significant part I have been following the Great [blog post](https://marcofranssen.nl/secure-your-software-supply-chain-using-sigstore-and-github-actions) of [Marco Franssen](https://twitter.com/marcofranssen) and doing further discovery on his excellent work.

I used a simple ‘Hello World’ nodeJS application that I can build with a Dockerfile and get the application build, generate SBOM and provenance and sign all the generated artefacts with `cosign`. I followed the steps as described in the blog post of Marco Franssen but made some tweaks to fit my workflow and I switched to the container provenance generation of the SLSA framework instead of the one from Philips labs. In a follow-up blog post, I plan to go deeper into provenance generation and learn more about its specifics of it. This was a great introduction to how to every step and integrate it within the CI pipeline.

The full pipeline I created can be found on my [GitHub](https://github.com/MattiasGees/S3C-demo).

## Verify container image

As the image has been signed through the GitHub Actions workload identity and uses [keyless signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md). The image signature can be verified in the following way:

```bash
COSIGN_EXPERIMENTAL=1 cosign verify mattiasgees/s3c-demo:main | jq


Verification for index.docker.io/mattiasgees/s3c-demo:main --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - Any certificates were verified against the Fulcio roots.
[
  {
    "critical": {
      "identity": {
        "docker-reference": "index.docker.io/mattiasgees/s3c-demo"
      },
      "image": {
        "docker-manifest-digest": "sha256:d2d824e2d2731b60cee1febd4797d6caa4b6039ccfc4d5b84143e4a699561a98"
      },
      "type": "cosign container image signature"
    },
    "optional": {
      "1.3.6.1.4.1.57264.1.1": "https://token.actions.githubusercontent.com",
      "1.3.6.1.4.1.57264.1.2": "push",
      "1.3.6.1.4.1.57264.1.3": "152303fdd0b6d00544c51ed492f30ba576c2c8ec",
      "1.3.6.1.4.1.57264.1.4": "Build",
      "1.3.6.1.4.1.57264.1.5": "MattiasGees/S3C-demo",
      "1.3.6.1.4.1.57264.1.6": "refs/heads/main",
      "Bundle": {
        "SignedEntryTimestamp": "MEQCIAt2t22tov8PDaOSqDoLk8W0sPQkaz5RJIu3FpdfRZXgAiA4spEbbBIpNGZ/KSm544WmaWYbMnZgXkW1BG76TFb5Hg==",
        "Payload": {
          "body": "eyJhcGlWZXJzaW9uIjoiMC4wLjEiLCJraW5kIjoiaGFzaGVkcmVrb3JkIiwic3BlYyI6eyJkYXRhIjp7Imhhc2giOnsiYWxnb3JpdGhtIjoic2hhMjU2IiwidmFsdWUiOiI0NzI5ZTFhZTZmMWZlZTYzZDhkYzZjMzczMGQzODM5OTY1ZWYwNGMyMmZhMmI0YjRiNTdjYTdlMTRiZWE1N2UxIn19LCJzaWduYXR1cmUiOnsiY29udGVudCI6Ik1FVUNJRHpUQ2hNclRGS212UW91VkI1WG4xMElTWmZ0eGY3bmNLTUlpdlh2NDUyVkFpRUE2SHg5aXpZRFgxWXJFWmYxZmQ1TUgzWGdEb0NpaDVsVGlTNUxQODkrV0tNPSIsInB1YmxpY0tleSI6eyJjb250ZW50IjoiTFMwdExTMUNSVWRKVGlCRFJWSlVTVVpKUTBGVVJTMHRMUzB0Q2sxSlNVUnJla05EUVhodFowRjNTVUpCWjBsVldUaFJlRlEwU0RsNFNFTk1VVWxTUldvNFprSlBjSFJEYjNKdmQwTm5XVWxMYjFwSmVtb3dSVUYzVFhjS1RucEZWazFDVFVkQk1WVkZRMmhOVFdNeWJHNWpNMUoyWTIxVmRWcEhWakpOVWpSM1NFRlpSRlpSVVVSRmVGWjZZVmRrZW1SSE9YbGFVekZ3WW01U2JBcGpiVEZzV2tkc2FHUkhWWGRJYUdOT1RXcEplRTFFUlRKTlZFRjVUbFJSTlZkb1kwNU5ha2w0VFVSRk1rMVVRWHBPVkZFMVYycEJRVTFHYTNkRmQxbElDa3R2V2tsNmFqQkRRVkZaU1V0dldrbDZhakJFUVZGalJGRm5RVVZtYmxaTmVrZ3daR1ZCVXpad1NrVlVRVWxWTkhWbGFITkxlSGw0WmpjMFMzSTJhR1FLWXpWTVZtMUZTVE01TUdwU1VWWnBNbnBpSzFkVGRYcExiRmwzUkVoSVdFZE9TWEZoTWxSaVdVeFVLelJvU1M4MWVFdFBRMEZxWjNkblowa3dUVUUwUndwQk1WVmtSSGRGUWk5M1VVVkJkMGxJWjBSQlZFSm5UbFpJVTFWRlJFUkJTMEpuWjNKQ1owVkdRbEZqUkVGNlFXUkNaMDVXU0ZFMFJVWm5VVlZGY1hkNkNtbHZkbFp5WWsweVVtWXdMMGx5VVUxdFdUSjBURWcwZDBoM1dVUldVakJxUWtKbmQwWnZRVlV6T1ZCd2VqRlphMFZhWWpWeFRtcHdTMFpYYVhocE5Ga0tXa1E0ZDFsUldVUldVakJTUVZGSUwwSkdZM2RXV1ZwVVlVaFNNR05JVFRaTWVUbHVZVmhTYjJSWFNYVlpNamwwVERBeGFHUklVbkJaV0U1SVdsZFdlZ3BNTVUxNlVYa3hhMXBYTVhaTWVUVnVZVmhTYjJSWFNYWmtNamw1WVRKYWMySXpaSHBNTWtveFlWZDRhMHh1YkhSaVJVSjVXbGRhZWt3eWFHeFpWMUo2Q2t3eU1XaGhWelIzVDFGWlMwdDNXVUpDUVVkRWRucEJRa0ZSVVhKaFNGSXdZMGhOTmt4NU9UQmlNblJzWW1rMWFGa3pVbkJpTWpWNlRHMWtjR1JIYURFS1dXNVdlbHBZU21waU1qVXdXbGMxTUV4dFRuWmlWRUZUUW1kdmNrSm5SVVZCV1U4dlRVRkZRMEpCVW5ka1dFNXZUVVJaUjBOcGMwZEJVVkZDWnpjNGR3cEJVVTFGUzBSRk1VMXFUWGROTWxwcldrUkNhVTV0VVhkTlJGVXdUa2ROTVUxWFZtdE9SR3Q1V21wTmQxbHRSVEZPZWxwcVRXMU5ORnBYVFhkRmQxbExDa3QzV1VKQ1FVZEVkbnBCUWtKQlVVWlJibFp3WWtkUmQwbG5XVXRMZDFsQ1FrRkhSSFo2UVVKQ1VWRlZWRmRHTUdSSGJHaGpNR1JzV2xoTmRsVjZUa1FLVEZkU2JHSlhPSGRJVVZsTFMzZFpRa0pCUjBSMmVrRkNRbWRSVUdOdFZtMWplVGx2V2xkR2EyTjVPWFJaVjJ4MVRVbEhTMEpuYjNKQ1owVkZRV1JhTlFwQloxRkRRa2gzUldWblFqUkJTRmxCUTBkRFV6aERhRk12TW1oR01HUkdja28wVTJOU1YyTlpja0paT1hkNmFsTmlaV0U0U1dkWk1tSXpTVUZCUVVkRUNqUkdVVlJDZDBGQlFrRk5RVko2UWtaQmFVVkJlazlJUWxZellYaE1LMnB4VjFGUVNXOXNTRFJ4V2xKU2NHcDVjMloyV1hGT0wxYzNNRE5MV21GME9FTUtTVU01TVVNclFUSnhOakJpTmpKRlkzZFZVbVpsVWtOM2NYSlVXblIyUmpCdllYQjJkR2R5YzBaUFpXOU5RVzlIUTBOeFIxTk5ORGxDUVUxRVFUSm5RUXBOUjFWRFRWRkVXV2xxTm5aelMyWmpUMFl4UlV4UFFtNU5NMDVWTkZCMFZubEhMMFJCVlVwVGFtWkZjalJOV1VGMGIxUnVaSEkyZEZodWJUVkhlRXQ1Q2pORlpDOUxSWGREVFVVMGFEUkhTMVV2U0VKbllrOTZiMjV4TW5oa056QkJRbkZ2VUdOUmVHSTRWVmRhVHpoa1Z6QklTM3A1ZUZWMFdVUkxTVFJtT0RBS2FGUkRXVFlyYTFwRFp6MDlDaTB0TFMwdFJVNUVJRU5GVWxSSlJrbERRVlJGTFMwdExTMEsifX19fQ==",
          "integratedTime": 1665915951,
          "logIndex": 5210671,
          "logID": "c0d23d6ad406973f9559f3ba2d1ca01f84147d8ffc5b8445c224f98b9591801d"
        }
      },
      "Issuer": "https://token.actions.githubusercontent.com",
      "Subject": "https://github.com/MattiasGees/S3C-demo/.github/workflows/build.yml@refs/heads/main",
      "githubWorkflowName": "Build",
      "githubWorkflowRef": "refs/heads/main",
      "githubWorkflowRepository": "MattiasGees/S3C-demo",
      "githubWorkflowSha": "152303fdd0b6d00544c51ed492f30ba576c2c8ec",
      "githubWorkflowTrigger": "push"
    }
  }
]
```

This tells us that a GitHub action has signed the image and also contains some information on the environment it has run in.

## Attest vs attach & sign

One of the things I investigated during the whole exercise was how to upload the SBOM and provenance data to my OCI registry. `cosign` has an `attest` and `attach` command.

The `attest` command generates a tag in the OCI registry formatted as `<image name>:<sha256-string>.att` and can have multiple layers to store all your attestations. In the example pipeline, it stores the SBOM and provenance in the `*.att` tag.

The advantage of the attest command over attach & sign is that you end up with less tags and the uploading & signing happens in one step. When you do attach & sign, you would create 2 tags (1 for the material and 1 for the signing information). The disadvantage of the attest command is that it is a bit harder to get the necessary information out. Let's say I want to extra my SBOM from the OCI registry I will need to run the following command

```bash
COSIGN_EXPERIMENTAL=1 cosign verify-attestation mattiasgees/s3c-demo:main --type spdxjson | jq '.payload |= @base64d | .payload | fromjson | select(.predicateType == "https://spdx.dev/Document") | .predicate.Data' > sbom-spdx.json
```

When you use `cosign attach`, you can use `cosign download` to get the SBOM in an easy way.

## Copying of images

Both `crane copy` and `cosign copy` will not only copy your container images from one OCI registry to another but also all of its associated [tags](https://twitter.com/mattomata/status/1580369338879836160?s=20&t=5VeEFzvgP2QauO6Rf0g-mA) (signatures, attestations).

## Enforcement

The last thing I did as part of my enforcement is deploy the Sigstore Policy Controller into my Kubernetes and enforce a simple policy where it checks if the container image comes from the GitHub action. 

```yaml
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: image-policy
spec:
  images:
  - glob: "**"
  authorities:
  - keyless:
      # Signed by the public Fulcio certificate authority
      url: https://fulcio.sigstore.dev
      identities:
      # Matches the Github Actions OIDC issuer
      - issuer: https://token.actions.githubusercontent.com
        # Matches a specific github workflow on main branch. Here we use the
        # sigstore policy controller example testing workflow as an example.
        subject: "https://github.com/MattiasGees/S3C-demo/.github/workflows/build.yml@refs/heads/main"
```

Sigstore Policy controller can do a lot more complex scenarios as well where it can match if specific [data](https://github.com/sigstore/policy-controller/blob/main/examples/policies/custom-key-attestation-sbom-spdxjson.yaml) is available in your SBOM, Provenance or any other type. This will be for a subsequent blogpost

## To end

This blog post only started to scratch the surface of the possibilities that can be done when you combine a whole lot of tools like cosign, syft, policy controllers, and OCI registries. I am continuing my research in this space and plan to publish more of my thoughts and experiments in the near future.
