terraform {
  backend "s3" {
    bucket  = "chenhan-terraform-playground"
    key     = "playground/aws-base"
    profile = "chenhan"
    region  = "ap-northeast-1"
  }
}

provider "aws" {
  profile = "chenhan"
  region  = "ap-northeast-1"
}


resource "aws_key_pair" "this" {
  key_name   = "chenhan"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3t+JdD1iW9VCLiATvoL3517B8iW/sDWUCtEh48nj+ujYnpXsk5H/fPABazv6aZ7QJjTL6dX5EyAca+GQtG5TS6TMtSuOVwbsCBIjMnep0Vcm+J8ZZCnfipiTJ18X44C/ITMf1GvtPiJiHsr6HYwWauFA1+PqgrMaRqGhIq9gScH82LjMF9KTjpquxML5xR+Bf1YlanPvSa2GpqnNd2v1uu1vRgIwD04ts9KdFWZJjSb00ey+zxVWfOpd0D5aNdf+Re97DDeLoG0j7jSfr+illm1y48q8vSICUdpVBlBtl5VPl/d2bMXzJ5gljsx7hjL5NVIy7LBChEYIz8T+f1V/1yy9VMiLvbWKC39H0tOtHbGc9htURiehEs2L+bmPx7z88gd6OOAyKUXre8k7bQzs3BBP1NjgQFM8zdsH7avd/GipLBJk0W6lmk9N1NuEDjzPj8BPDxrr1HDn4MKJvktBImPgPTrrvyMWmPmed36O1DAH8DMnd0snDc2bIjkEqcYkdaPjZLYLXfFIeD8bFHZNez+nU8jqEvFF0IKRID2NK1Tbsrh0dC+yOpK9vd5kTFpzRLZYt+hptuAQx21Syg0ItNCYrSwiIDYupndq1guUNvgHY1vOIwvlgRvf+34t3FF1Hk7UoEl7cDHDEj37HM3bAJx1u9Um88TNdQXJc/Lx6Xw== chenhan.hsiao.tw@gmail.com"
}