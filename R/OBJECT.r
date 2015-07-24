#' @title Retrieves an object from an S3 bucket
#' 
#' @param bucket A character string containing the name of the bucket you want to get.
#' @param object A character string containing the name of the object you want to get from that bucket.
#' @param ... Additional arguments passed to \code{\link{s3HTTP}}.
#'
#' @return A raw object.
#' @export

getobject <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    h <- list()
    r <- s3HTTP(verb = "GET", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                headers = c(h, `x-amz-content-sha256` = ""), 
                parse_response = FALSE,
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        r
    }
}

print.s3_object <- function(x, ...){
    cat("Key:           ", x$Key, "\n")
    cat("Modified:      ", x$LastModified, "\n")
    cat("ETag:          ", x$ETag, "\n")
    cat("Size (kb):     ", x$Size, "\n")
    cat("Owner:         ", x$Owner$DisplayName, "\n")
    cat("Storage class: ", x$StorageClass, "\n")
    invisible(x)
}


get_acl <- function(bucket, object, ...) {
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    if (missing(object)) {
        r <- s3HTTP(verb = "GET", 
                    url = paste0("https://", bucket, ".s3.amazonaws.com"),
                    path = "/?acl",
                    headers = list(`x-amz-content-sha256` = ""), 
                    ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            structure(r, class = "s3_bucket")
        }
    } else {
        if (inherits(object, "s3_object"))
            object <- object$Key
        r <- s3HTTP(verb = "GET", 
                    url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                    path = "/?acl",
                    headers = list(`x-amz-content-sha256` = ""), 
                    ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            structure(r, class = "s3_object")
        }
    }
}

get_torrent <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "GET", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                path = "/?torrent",
                headers = list(`x-amz-content-sha256` = ""), 
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        structure(r, class = "s3_object")
    }
}


# HEAD

headobject <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "HEAD", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                headers = list(`x-amz-content-sha256` = ""), 
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        structure(r, class = "HEAD")
    }
}


# OPTIONS

optsobject <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "OPTIONS", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                headers = list(`x-amz-content-sha256` = ""), 
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        structure(r, class = "s3_object")
    }
}


# POST

postobject <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "POST", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                headers = list(`x-amz-content-sha256` = ""), 
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        structure(r, class = "s3_object")
    }
}



# PUT

#' @title Puts an object into an S3 bucket
#'
#' @param file A character string containing the filename (or full path) of the file you want to upload to S3.
#' @param bucket A character string containing the name of the bucket you want to put an object into.
#' @param object A character string containing the name the object should have in S3 (i.e., its "object key"). If missing, the filename is used.
#'
#' @return A list, containing the AWS API response.
#' @export

putobject <- function(file, bucket, object, ...) {
    if (!missing(object) && inherits(object, "s3_object"))
        object <- object$Key
    if (missing(object)) {
        object <- basename(file)
    }
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "PUT", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                headers = list(`Content-Length` = file.size(file), 
                               `x-amz-content-sha256` = ""), 
                request_body = file,
                ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        structure(r, class = "s3_object")
    }
}

putobject_acl <- function(bucket, object, ...) {
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    if (missing(object)) {
        r <- s3HTTP(verb = "PUT", 
                    url = paste0("https://", bucket, ".s3.amazonaws.com"),
                    path = "/?acl",
                    headers = list(`x-amz-content-sha256` = ""), 
                    ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            structure(r, class = "s3_bucket")
        }
    } else {
        if (inherits(object, "s3_object"))
            object <- object$Key
        r <- s3HTTP(verb = "PUT", 
                    url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
                    headers = list(`x-amz-content-sha256` = ""), 
                    ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            structure(r, class = "s3_object")
        }
    }
}

copyobject <- function(from_object, to_object, from_bucket, to_bucket, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    r <- s3HTTP(verb = "PUT", 
                url = paste0("https://", bucket, ".s3.amazonaws.com/", object), 
               headers = list(`x-amz-content-sha256` = ""), 
               ...)
    if (inherits(r, "aws_error")) {
        return(r)
    } else {
        return(r, class = "s3_object")
    }
}


# DELETE

deleteobject <- function(bucket, object, ...) {
    if (inherits(object, "s3_object"))
        object <- object$Key
    if (inherits(bucket, "s3bucket"))
        bucket <- bucket$Name
    if (length(object) == 1) {
        r <- s3HTTP(verb = "DELETE", 
                    url = paste0("https://", bucket, ".s3.amazonaws.com/", object), ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            TRUE
        }
    } else {
        r <- httr::POST(paste0("https://", bucket, ".s3.amazonaws.com/?delete"), ...)
        if (inherits(r, "aws_error")) {
            return(r)
        } else {
            return(r, class = "s3_object")
        }
    }
    return(r)
}
