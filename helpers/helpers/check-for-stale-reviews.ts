const rawJson = await new Response(Deno.stdin.readable).json()

const getNewCommits = (pr) => {
  const myReview = pr.latestReviews?.find(review => review.author.login == 'r-k-b')

  if (myReview === null) {
    return { number: pr.number, info: 'no reviews of mine' }
  }

  const reviewTime = new Date(myReview.submittedAt)

  const newCommits = pr.commits.filter(commit => {
    const commitTime = new Date(commit.authoredDate).getTime()
    const result = commitTime > reviewTime.getTime()
    return result
  })

  return { number: pr.number, newCommitsCount: newCommits.length, reviewTime, reviewState: myReview.state }
}

console.log(rawJson.map(getNewCommits))
