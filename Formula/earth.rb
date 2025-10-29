class Earth < Formula
  desc "Build automation tool for the container era"
  homepage "https://github.com/earthbuild"
  url "https://github.com/EarthBuild/earthbuild.git",
    tag: "v0.8.17",
      revision: "52f2da6dd7f3de24a60a76e00044ec560b0ea407"
  license "MPL-2.0"
  head "https://github.com/EarthBuild/earthbuild.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "194e4b767c3d1a551453ceb3739345c84de89533768b352e3b339d116497a238"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v0.8.16
      -X main.Version=v#{version}
      -X main.GitSha=#{Utils.git_head}
      -X main.BuiltBy=homebrew-earthbuild
    ]
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build", "-tags", tags, *std_go_args(ldflags: ldflags, output: bin/"earth"), "./cmd/earthly"

    bin.install_symlink "earth" => "earthly"

    generate_completions_from_executable(bin/"earth", "bootstrap", "--source", shells: [:bash, :zsh])
  end

  test do
    # earthbuild requires docker to run; therefore doing a complete end-to-end test here is not
    # possible; however the "earthbuild ls" command is able to run without docker.
    (testpath/"Earthfile").write <<~EOS
      VERSION 0.8
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earthly ls")
    assert_match "+mytesttarget", output
  end
end
